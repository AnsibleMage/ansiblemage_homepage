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
    # TODO: Implement GitHub API call
    # For now, return static data
    [
      {
        name: "ansiblemage",
        description: "Mastering the 'True Names' of digital objects through code.",
        language: nil,
        stars: 0,
        url: "https://github.com/AnsibleMage/ansiblemage"
      },
      {
        name: "ansible_config",
        description: "The ignition sequence for the Ansible Station. Global configuration files and skill sets for AI sub-agents.",
        language: "Python",
        stars: 0,
        url: "https://github.com/AnsibleMage/ansible_config"
      },
      {
        name: "ansible_projects",
        description: "The Manifestation Sector of the Ansible. Realizing the coordinates of Vibe Coding across any digital frontier.",
        language: "TypeScript",
        stars: 0,
        url: "https://github.com/AnsibleMage/ansible_projects"
      }
    ]
  end
end
