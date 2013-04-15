require "htmlentities"
require "open-uri"
require "nokogiri"
require "cgi"

# TODO: remove empty tags
# def is_blank?(node)
#   node.text? && node.content.strip == ''
# end
# def all_children_are_blank?(node)
#   node.children.all?{ |child| is_blank?(child) }
# end
# doc.xpath("//*").find_all{ |p| all_children_are_blank?(p) }.each do |p|
#   puts p
#   p.remove
# end

output = "out.html"
url = "https://docs.google.com/document/d/1fUye_omrE5jgMnljL9ZuvK-BJUhyRM6dCQ8KTtunC70"

default_style = <<-HTML
  <style type="text/css">
    #menu {
      float: left; top: 150px; background: #f6f6f6; width: 230px; border-radius: 4px; border: 1px solid #eee;
      padding: 0 10px 5px 10px;
    }
    .docs-content { /* margin-left: 280px; float:left; padding-left: 270px; width: 700px; */ }
    .docs-content img { border-radius: 2px; margin: 10px; box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.3); max-width: 600px; }
    .disclaimer { color: red; }
    #menu.affix { top: 20px; }
    a.anchor { margin-top: 20px; }
    //p, span { text-align: left !important; }
    //.center-image { text-align: center !important; }
  </style>
  HTML

doc = Nokogiri::HTML(open("#{url}/pub"), nil, 'UTF-8')

# We want the second <style> block
style = doc.xpath("//style")[1]

# Fix images
doc.css("img").each do |img|
  # # The parent is centered
  # parent = img.parent
  # parent['class'] ||= ""
  # parent['class'] = parent['class'] << " center-image"

  # The src was relative
  unless img.attributes["src"].nil?
    img.attributes["src"].value = "#{url}/#{img.attributes["src"].value}"
  end
end

# Remove the title
doc.xpath('//*[contains(@class, "title")]').remove

# The content we want
content = doc.xpath("//*[preceding-sibling::style]")

# Wrap the content in a class we can style
content = Nokogiri.make("<div class='docs-content'>#{content.to_html}</div>")

# Write it
File.open(output, "w:UTF-8") do |file|
  file.write(HTMLEntities.new.decode(style.to_s))
  file.write(HTMLEntities.new.decode(default_style.to_s))
  file.write(HTMLEntities.new.decode(content.to_s))
end