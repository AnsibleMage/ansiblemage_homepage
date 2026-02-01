class PagesController < ApplicationController
  def home
    @recent_posts = Post.published.order(created_at: :desc).limit(3) if defined?(Post)
  end

  def about
  end

  def projects
    @repos = fetch_github_repos
  end

  private

  def fetch_github_repos
    Rails.cache.fetch("github_repos", expires_in: 1.hour) do
      fetch_repos_from_api
    end
  rescue StandardError => e
    Rails.logger.error "GitHub API error: #{e.message}"
    fallback_repos
  end

  def fetch_repos_from_api
    uri = URI("https://api.github.com/users/AnsibleMage/repos?sort=updated&per_page=9")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.github.v3+json"
    request["User-Agent"] = "AnsibleMage-Homepage"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body).map do |repo|
        {
          name: repo["name"],
          description: repo["description"],
          language: repo["language"],
          stars: repo["stargazers_count"],
          forks: repo["forks_count"],
          url: repo["html_url"]
        }
      end
    else
      fallback_repos
    end
  end

  def fallback_repos
    [
      {
        name: "ansiblemage",
        description: "Mastering the 'True Names' of digital objects through code.",
        language: nil,
        stars: 0,
        forks: 0,
        url: "https://github.com/AnsibleMage/ansiblemage"
      },
      {
        name: "ansible_config",
        description: "The ignition sequence for the Ansible Station. Global configuration files and skill sets for AI sub-agents.",
        language: "Python",
        stars: 0,
        forks: 0,
        url: "https://github.com/AnsibleMage/ansible_config"
      },
      {
        name: "ansible_projects",
        description: "The Manifestation Sector of the Ansible. Realizing the coordinates of Vibe Coding across any digital frontier.",
        language: "TypeScript",
        stars: 0,
        forks: 0,
        url: "https://github.com/AnsibleMage/ansible_projects"
      }
    ]
  end
end
