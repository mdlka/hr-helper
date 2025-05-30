import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "item" ]

  connect() {
    console.log("Skill search controller connected")
  }

  search() {
    const searchTerm = this.inputTarget.value.toLowerCase()
    
    this.itemTargets.forEach(item => {
      const skill = item.querySelector('input').dataset.skill
      if (skill.includes(searchTerm)) {
        item.style.display = ''
      } else {
        item.style.display = 'none'
      }
    })
  }
} 