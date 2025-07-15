// Order Project JavaScript Module
let orderProject;

class OrderProject {
  constructor() {
    this.selectedVideos = [];
    this.init();
  }
  
  init() {
    // Initialize event listeners if needed
    console.log('OrderProject initialized');
  }
  
  handleCardClick(event, card) {
    event.preventDefault();
    event.stopPropagation();
    
    const videoTypeId = card.dataset.videoTypeId;
    console.log('Card clicked:', videoTypeId);
    
    const index = this.selectedVideos.indexOf(videoTypeId);
    if (index > -1) {
      // Remove video type
      this.selectedVideos.splice(index, 1);
      card.classList.remove('selected');
    } else {
      // Add video type
      this.selectedVideos.push(videoTypeId);
      card.classList.add('selected');
    }
    
    console.log('Selected videos:', this.selectedVideos);
    this.updateCartSummary();
  }
  
  updateCartSummary() {
    const cartItems = document.getElementById('cartItems');
    const totalAmount = document.getElementById('totalAmount');
    const payButton = document.getElementById('payButton');
    
    if (this.selectedVideos.length === 0) {
      cartItems.innerHTML = '<p class="text-muted">No items selected</p>';
      totalAmount.textContent = '0';
      payButton.disabled = true;
      return;
    }
    
    let html = '';
    let total = 0;
    
    this.selectedVideos.forEach(videoTypeId => {
      const card = document.querySelector(`[data-video-type-id="${videoTypeId}"]`);
      const title = card.querySelector('.card-title').textContent;
      const price = parseFloat(card.querySelector('.price-tag').textContent.replace('$', ''));
      
      total += price;
      html += `
        <div class="cart-item">
          <div>
            <strong>${title}</strong>
          </div>
          <div class="text-end">
            <strong>$${price}</strong>
            <button type="button" class="btn btn-sm btn-outline-danger ms-2" onclick="removeFromCart('${videoTypeId}', event)">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
      `;
    });
    
    cartItems.innerHTML = html;
    totalAmount.textContent = total.toFixed(2);
    payButton.disabled = false;
  }
  
  removeFromCart(videoTypeId, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    
    const card = document.querySelector(`[data-video-type-id="${videoTypeId}"]`);
    if (card) {
      card.classList.remove('selected');
      const index = this.selectedVideos.indexOf(videoTypeId);
      if (index > -1) {
        this.selectedVideos.splice(index, 1);
        this.updateCartSummary();
      }
    }
  }
  
  openPaymentModal() {
    const projectName = document.getElementById('projectName').value;
    const footageLink = document.getElementById('footageLink').value;
    
    if (!projectName || !footageLink) {
      alert('Please fill in project name and footage link');
      return;
    }
    
    const orderSummary = document.getElementById('orderSummary');
    const modalTotalAmount = document.getElementById('modalTotalAmount');
    const total = document.getElementById('totalAmount').textContent;
    
    let summaryHtml = `
      <div class="mb-3">
        <strong>Project:</strong> ${projectName}<br>
        <strong>Footage:</strong> <a href="${footageLink}" target="_blank">View Link</a>
      </div>
    `;
    
    this.selectedVideos.forEach(videoTypeId => {
      const card = document.querySelector(`[data-video-type-id="${videoTypeId}"]`);
      const title = card.querySelector('.card-title').textContent;
      const price = card.querySelector('.price-tag').textContent;
      summaryHtml += `
        <div class="cart-item">
          <div><strong>${title}</strong></div>
          <div class="text-end"><strong>${price}</strong></div>
        </div>
      `;
    });
    
    orderSummary.innerHTML = summaryHtml;
    modalTotalAmount.textContent = total;
    
    const modal = new bootstrap.Modal(document.getElementById('paymentModal'));
    modal.show();
  }
  
  processPayment() {
    const button = event.target;
    const originalText = button.innerHTML;
    button.innerHTML = '<div class="loader"></div>';
    button.disabled = true;
    
    const projectData = {
      project: {
        name: document.getElementById('projectName').value,
        footage_link: document.getElementById('footageLink').value
      },
      video_type_ids: this.selectedVideos
    };
    
    // First process the payment
    fetch('/projects/process_payment', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(projectData)
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        // If payment successful, create the project
        return fetch('/projects', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify(projectData)
        });
      } else {
        throw new Error(data.message);
      }
    })
    .then(response => response.json())
    .then(data => {
      window.location.href = '/projects';
    })
    .catch(error => {
      alert('Error: ' + error.message);
      button.innerHTML = originalText;
      button.disabled = false;
    });
  }
}

// Initialize immediately and set up global functions
orderProject = new OrderProject();
window.orderProject = orderProject;

// Global functions for backward compatibility
window.handleCardClick = function(event, card) {
  orderProject.handleCardClick(event, card);
};

window.removeFromCart = function(videoTypeId, event) {
  orderProject.removeFromCart(videoTypeId, event);
};

window.openPaymentModal = function() {
  orderProject.openPaymentModal();
};

window.processPayment = function() {
  orderProject.processPayment();
};
