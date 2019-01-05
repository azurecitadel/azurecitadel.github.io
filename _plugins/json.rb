#
# Mostly stole & then heavily modified this plugin to output as JSON
# 
# Ben C, Jan 2019
#

module Jekyll
  class JSONPage < Page
    def initialize(site, base, dir, name, content)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.data = {}
      self.content = content

      process(@name)
    end

    def read_yaml(*)
      # Do nothing
    end

    def render_with_liquid?
      false
    end
  end

  class JSONPostGenerator < Generator
    safe true

    def generate(site)
      site.pages.each do |post|
        # Set the path to the JSON version of the post
        dest = site.config['destination']

        # Only work with our markdown conten
        unless post.name.end_with? ".md"
          next
        end

        path = post.destination(dest)
        path["#{dest}/"] = ''
        path['/index.html'] = '.json'

        # Convert the post to a hash
        output = post.to_liquid

        # Prepare the output for JSON conversion
        ['dir', 'layout', 'path'].each do |key|
          output.delete(key)
        end

        output['content_html'] = post.transform
        output['content_md'] = output.delete('content')

        site.pages << JSONPage.new(site, site.source, File.dirname(path), File.basename(path), output.to_json)
      end
    end
  end
end