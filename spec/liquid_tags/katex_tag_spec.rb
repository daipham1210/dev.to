require "rails_helper"

RSpec.describe KatexTag, type: :liquid_tag do
  describe "#render" do
    def generate_katex_liquid(content)
      Liquid::Template.register_tag("katex", described_class)
      Liquid::Template.parse("{% katex %}#{content}{% endkatex %}")
    end

    it "generates Katex output" do
      content = "c = \\pm\\sqrt{a^2 + b^2}"
      rendered = generate_katex_liquid(content).render
      verify(format: :html) { rendered }
    end

    it "includes the css style tag only once when rendering multiple" do
      content = <<~CONTENT
        {% katex %}
          hello
        {% endkatex %}
        {% katex %}
          Hello
        {% endkatex %}
      CONTENT
      Liquid::Template.register_tag("katex", described_class)
      render = Liquid::Template.parse(content).render
      expect(Nokogiri::HTML(render).css("link").count).to eq(1)
    end

    it "generates Katex errors" do
      content = "\\c = \\pm\\sqrt{a^2 + b^2}"
      rendered = generate_katex_liquid(content).render
      expect(rendered).to include("ParseError: KaTeX parse error: ")
    end
  end
end
