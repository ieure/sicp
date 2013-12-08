from collections import defaultdict, Counter
from HTMLParser import HTMLParser
import os.path
import re
import sys
from urlparse import urldefrag
from xml.etree import ElementTree

ncx_namespace = 'http://www.daisy.org/z3986/2005/ncx/'

ElementTree.register_namespace('', ncx_namespace)

toc_file = sys.argv[1]
content_dir, _ = os.path.split(toc_file)

found_sections = defaultdict(Counter)


def _tag_name(name):
    return '{{{0}}}{1}'.format(ncx_namespace, name)


def _section_id(section_number):
    return '__sec_' + section_number


def subsection_source(content_src, subsection_number):
    section_number = subsection_match.group(1)
    section_id = _section_id(section_number)

    new_src = '#'.join([content_src, section_id])
    return new_src


class SectionFinder(HTMLParser):
    def __init__(self, src_file, section_title):
        HTMLParser.__init__(self)
        self.last_id = None
        self.new_src = None
        self.consume_text = False
        self.current_text = ''
        self.section_title = section_title
        self.src_file = src_file
        self.section_title_index = found_sections[src_file][section_title]
        self.found_sections = 0

    def build_src(self, anchor_id):
        return '#'.join([self.src_file, anchor_id])

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and 'id' in attrs:
            self.last_id = attrs['id']
        elif self.last_id is not None and tag.startswith('h'):
            self.consume_text = True

    def handle_endtag(self, tag):
        if self.last_id and tag.startswith('h'):
            if self.current_text == self.section_title:
                if self.found_sections == self.section_title_index:
                    self.new_src = self.build_src(self.last_id)
                    found_sections[self.src_file][self.section_title] += 1

                self.found_sections += 1

            self.last_id = None
            self.consume_text = False
            self.current_text = ''

    def handle_data(self, data):
        if self.consume_text:
            self.current_text += data


def find_content_source(section_title, content_src):
    source_path = os.path.join(content_dir, content_src)
    section_finder = SectionFinder(content_src, section_title)

    with open(source_path) as source_file:
        section_finder.feed(source_file.read())

    return section_finder.new_src


doc = ElementTree.parse(toc_file)

for nav_point in doc.iter(_tag_name('navPoint')):
    text_node = nav_point.find(_tag_name('navLabel')).find(_tag_name('text'))
    content_node = nav_point.find(_tag_name('content'))

    if text_node is None or content_node is None:
        continue

    old_src = content_node.get('src')
    content_src, fragment = urldefrag(old_src)

    if not fragment:
        continue

    subsection_match = re.match(r'^([0-9.]+)', text_node.text)
    if subsection_match:
        new_src = subsection_source(content_src, subsection_match.group(1))
    else:
        new_src = find_content_source(text_node.text, content_src)

    if new_src is None:
        print 'Cannot find reference for {0} in {1}'.format(text_node.text, content_src)
        continue

    print old_src, '->', new_src

    content_node.set('src', new_src)

doc.write(toc_file + '-new', xml_declaration=True, encoding='UTF-8')
