class TwitterCard
  attr_accessor :type, :header, :body, :img, :url
  
  # TwitterCard.new(header: "", body: "", img: "", url: "")
  def initialize(hsh = {})
    @type = hsh[:summary].nil? ? "summary" : hsh[:summary]
    @header = hsh[:header].nil? ? "Missing Header" : hsh[:header]
    @body = hsh[:body].nil? ? "" : hsh[:body]
    @img = hsh[:img].nil? ? "" : hsh[:img]
    @url = hsh[:url].nil? ? "" : hsh[:url]
  end
  
  def render
    renderer = ERB.new(get_template)
    renderer.result(binding).html_safe
  end
  
  def get_template
    template = <<-END
      <meta name="twitter:card" content="<%=self.type%>" />
      <meta name="twitter:site" content="@anonlit" />
      <meta name="twitter:title" content="<%=self.header%>" />
      <meta name="twitter:description" content="<%=self.body%>" />
      <meta name="twitter:image" content="<%="#{$BitcoinCallbackDomain}#{self.img}"%>" />
      <meta name="twitter:url" content="<%= "#{$BitcoinCallbackDomain}#{self.url}"%>" />
      
    END
  end
  
end