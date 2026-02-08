import { Controller } from "@hotwired/stimulus"

// Tag filter controller for dynamic tag filtering with Turbo Frames
export default class extends Controller {
  connect() {
    // Controller is connected - tags will use Turbo Frame for filtering
    console.log("Tag filter controller connected")
  }

  // Filter posts by tag
  filter(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag

    // Update URL and trigger Turbo Frame
    const url = tag ? `/posts?tag=${encodeURIComponent(tag)}` : '/posts'
    window.Turbo.visit(url, { frame: "posts" })
  }
}
