# Clear existing data
puts "Cleaning database..."
Notification.destroy_all
Video.destroy_all
Project.destroy_all
VideoType.destroy_all
User.destroy_all

# Create Project Managers
puts "Creating Project Managers..."
pms = [
  { name: "Sarah Johnson", email: "sarah.j@wanderlust.com" },
  { name: "Mike Chen", email: "mike.c@wanderlust.com" },
  { name: "Emma Davis", email: "emma.d@wanderlust.com" }
].map do |pm_data|
  User.create!(
    name: pm_data[:name],
    email: pm_data[:email],
    role: :pm
  )
end

# Create Clients
puts "Creating Clients..."
clients = [
  { name: "John Smith", email: "john.smith@example.com" },
  { name: "Alice Brown", email: "alice.b@example.com" },
  { name: "David Wilson", email: "david.w@example.com" },
  { name: "Maria Garcia", email: "maria.g@example.com" },
  { name: "Tom Anderson", email: "tom.a@example.com" }
].map do |client_data|
  User.create!(
    name: client_data[:name],
    email: client_data[:email],
    role: :client
  )
end

# Create Video Types
puts "Creating Video Types..."
video_types = [
  {
    name: "Highlight Reel",
    price: 299.99,
    format: "16:9 HD (1920x1080)"
  },
  {
    name: "Full Documentary",
    price: 999.99,
    format: "16:9 4K (3840x2160)"
  },
  {
    name: "Social Media Teaser",
    price: 149.99,
    format: "1:1 Square (1080x1080)"
  },
  {
    name: "Instagram Story",
    price: 199.99,
    format: "9:16 Vertical (1080x1920)"
  },
  {
    name: "Wedding Highlights",
    price: 499.99,
    format: "16:9 4K (3840x2160)"
  }
].map do |type_data|
  VideoType.create!(type_data)
end

# Create Projects with Videos
puts "Creating Projects and Videos..."
project_statuses = [ "in_progress", "completed", "draft" ]

15.times do |i|
  # Create project
  project = Project.create!(
    name: "Project #{i + 1}",
    footage_link: "https://footage-storage.wanderlust.com/raw/project-#{i + 1}",
    total_price: 0, # Will be updated after adding videos
    status: project_statuses.sample,
    client: clients.sample,
    pm: pms.sample
  )

  # Add 1-3 videos to each project
  selected_video_types = video_types.sample(rand(1..3))
  selected_video_types.each do |video_type|
    Video.create!(
      project: project,
      video_type: video_type
    )
  end

  # Update total price
  total = project.videos.sum { |video| video.video_type.price }
  project.update!(total_price: total)
end

# Create Notifications
puts "Creating Notifications..."
Project.all.each do |project|
  # Create notification for project creation
  Notification.create!(
    user: project.pm,
    project: project,
    message: "New project '#{project.name}' assigned to you",
    read: [ true, false ].sample
  )

  # Create some additional notifications for variety
  if project.status == "Completed"
    Notification.create!(
      user: project.client,
      project: project,
      message: "Your project '#{project.name}' has been completed!",
      read: [ true, false ].sample
    )
  elsif project.status == "In Progress"
    Notification.create!(
      user: project.client,
      project: project,
      message: "Your project '#{project.name}' is being processed",
      read: [ true, false ].sample
    )
  end
end

puts "Seed completed!"
puts "Created:"
puts "- #{User.where(role: :pm).count} Project Managers"
puts "- #{User.where(role: :client).count} Clients"
puts "- #{VideoType.count} Video Types"
puts "- #{Project.count} Projects"
puts "- #{Video.count} Videos"
puts "- #{Notification.count} Notifications"
