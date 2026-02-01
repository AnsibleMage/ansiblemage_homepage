module ApplicationHelper
  def language_color(language)
    colors = {
      "Ruby" => "bg-red-500",
      "Python" => "bg-blue-500",
      "TypeScript" => "bg-blue-400",
      "JavaScript" => "bg-yellow-400",
      "Go" => "bg-cyan-400",
      "Rust" => "bg-orange-500",
      "HTML" => "bg-orange-400",
      "CSS" => "bg-purple-400"
    }
    colors[language] || "bg-gray-400"
  end
end
