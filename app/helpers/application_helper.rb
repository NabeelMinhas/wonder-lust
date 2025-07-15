module ApplicationHelper
  def formatted_date(date)
    date.strftime("%B %d, %Y")
  end
  
  def formatted_price(price)
    "$#{price.to_f.round(2)}"
  end
  
  def status_badge(status)
    case status.to_s
    when 'in_progress'
      content_tag :span, 'In Progress', class: 'badge bg-warning'
    when 'completed'
      content_tag :span, 'Completed', class: 'badge bg-success'
    when 'draft'
      content_tag :span, 'Draft', class: 'badge bg-secondary'
    else
      # content_tag :span, status.titleize, class: 'badge bg-info'
    end
  end
  
  def project_action_button(project, text: 'View Details', icon: 'fas fa-eye')
    link_to project_path(project), class: "btn btn-primary" do
      content_tag(:i, '', class: "#{icon} me-2") + text
    end
  end
  
  def empty_state(title:, message:, action_text: nil, action_path: nil, icon: 'fas fa-folder-open')
    content_tag :div, class: 'empty-state' do
      content_tag(:i, '', class: "#{icon} empty-state-icon") +
      content_tag(:h3, title) +
      content_tag(:p, message) +
      (action_text && action_path ? 
        link_to(action_path, class: 'btn btn-primary') do
          content_tag(:i, '', class: 'fas fa-plus me-2') + action_text
        end : '')
    end
  end
end
