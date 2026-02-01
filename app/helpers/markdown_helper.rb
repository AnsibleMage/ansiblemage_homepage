module MarkdownHelper
  class PixelCodeRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def block_code(code, language)
      lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText.new
      formatter = Rouge::Formatters::HTMLInline.new(PixelTheme.new)

      %(<pre class="pixel-code"><code class="highlight">#{formatter.format(lexer.lex(code))}</code></pre>)
    end
  end

  class PixelTheme < Rouge::Themes::Base16
    name 'pixel'

    palette base00: "#0D0D0D"  # void-black
    palette base01: "#1A1A2E"  # dark-space
    palette base02: "#2D1B4E"  # deep-purple
    palette base03: "#6B5B95"  # space-purple
    palette base04: "#B0B0B0"  # moon-gray
    palette base05: "#F0F0F0"  # star-white
    palette base06: "#F0F0F0"
    palette base07: "#FFFFFF"
    palette base08: "#FF6B6B"  # pixel-red
    palette base09: "#FFD700"  # pixel-gold
    palette base0A: "#FFD700"  # pixel-gold
    palette base0B: "#39FF14"  # neon-green
    palette base0C: "#00FFFF"  # neon-cyan
    palette base0D: "#00FFFF"  # neon-cyan
    palette base0E: "#FF00FF"  # neon-magenta
    palette base0F: "#FF6B6B"  # pixel-red
  end

  def markdown(text)
    return '' if text.blank?

    renderer = PixelCodeRenderer.new(
      hard_wrap: true,
      link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      highlight: true,
      quote: true,
      footnotes: true
    )

    markdown.render(text).html_safe
  end
end
