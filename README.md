# Wanderlust Videos

A comprehensive video project submission and management application built with Ruby on Rails. This mini-app allows clients to create video projects, select video types, and manage their video editing requests with automatic project manager assignment and background job processing.

## 🚀 Demo Video
https://jam.dev/c/d2eed49d-ad93-475a-8cc1-11f914a3958b

## 🚀 Features

- **Client Project Management**: Clients can view their projects and create new ones
- **Video Type Selection**: Choose from different video editing services with pricing
- **Payment Simulation**: Mock payment processing with modal interface
- **Project Manager Assignment**: Automatic PM assignment for new projects
- **Background Notifications**: Asynchronous notification system using Active Job
- **Responsive Design**: Mobile-first UI with Bootstrap 5
- **Comprehensive Testing**: 98 tests with full coverage

## 📋 Requirements

### System Requirements
- **Ruby**: 3.3.4 (recommended) or 3.3.x
- **Rails**: 7.2.2.1 or higher
- **Database**: MySQL 8.0+ (or compatible)
- **Node.js**: 16.0+ (for asset compilation)
- **Git**: For version control

### Dependencies
- **RVM or rbenv**: For Ruby version management
- **Bundler**: For gem management
- **MySQL**: Database server
- **Redis**: (optional, for production background jobs)

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd wanderlust_videos
```

### 2. Ruby Version Setup
Using RVM:
```bash
# Install Ruby 3.3.4 if not already installed
rvm install 3.3.4
rvm use 3.3.4

# Or switch to the project Ruby version
rvm use $(cat .ruby-version)
```

Using rbenv:
```bash
# Install Ruby 3.3.4 if not already installed
rbenv install 3.3.4
rbenv local 3.3.4
```

### 3. Install Dependencies
```bash
# Install gems
bundle install
```

### 4. Database Setup
```bash
# Create and setup database
rails db:create
rails db:migrate

# Load seed data
rails db:seed
```

### 5. Configuration
```bash
# Copy environment configuration (if needed)
cp config/database.yml.example config/database.yml

# Edit database configuration
vim config/database.yml
```

### 6. Start the Application
```bash
# Start the Rails server
rails server

# Or with specific port
rails server -p 3000
```

Visit `http://localhost:3000` to access the application.

## 🌱 Seed Data

The application comes with seed data for testing and development:

```bash
# Run the seed file
rails db:seed

# Or reset and reseed
rails db:reset
```

### Seed Data Includes:
- **Users**: Sample clients and project managers
- **Video Types**: Different video editing services (Highlight Reel, Social Media, Documentary, etc.)
- **Projects**: Sample projects in various states
- **Notifications**: Sample notifications for testing

### Sample Data Access:
- **Clients**: Access dashboard at root URL
- **Project Managers**: Can view assigned projects
- **Video Types**: Available for project creation

## 🧪 Testing

### Running Tests

```bash
# Run all tests
rails test
```

### Test Coverage
- **98 tests** with 0 failures
- **Model Tests**: User, Project, VideoType validation and associations
- **Service Tests**: ProjectCreationService, PaymentService business logic
- **Job Tests**: NotificationJob background processing
- **Integration Tests**: Complete user workflows

### Test Database
```bash
# Setup test database
rails db:test:prepare

# Reset test database
rails db:test:reset
```

## 🔧 Development



### Code Quality
```bash
# Run code linting (if configured)
rubocop

# Run security checks (if configured)
brakeman
```

## 🏗️ Architecture

### Models
- **User**: Clients and Project Managers with role-based access
- **Project**: Main project entity with status tracking
- **Video**: Junction table for project-video type associations
- **VideoType**: Video editing service definitions
- **Notification**: System notifications for users

### Controllers
- **ApplicationController**: Base controller with common functionality
- **DashboardController**: Client dashboard and project overview
- **ProjectsController**: Project CRUD operations and payment processing

### Services
- **ProjectCreationService**: Transaction-safe project creation
- **PaymentService**: Mock payment processing simulation

### Jobs
- **NotificationJob**: Background notification processing with retry logic

### Views
- **Responsive Bootstrap UI**: Mobile-first design
- **Reusable Partials**: Hero sections, project cards, navigation
- **Form Helpers**: Enhanced form components

## 🌐 API Endpoints

### Projects
- `GET /` - Dashboard (root)
- `GET /projects` - List projects
- `GET /projects/:id` - Show project details
- `GET /projects/order_new` - New project form
- `POST /projects` - Create project
- `POST /projects/process_payment` - Process payment
- `GET /projects/:id/view_footage` - View footage (coming soon)

### Video Types
- `GET /video_types` - List available video types




## 📊 Background Job System

### Configuration
- **Queue**: `:default`
- **Adapter**: `:async` (development), Sidekiq (production)
- **Retries**: 3 attempts with exponential backoff
- **Error Handling**: Discards jobs for deleted records

### Job Types
- **NotificationJob**: Creates notifications for PM assignments
