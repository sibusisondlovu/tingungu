/* ===================================================================
 * Tingungu Modern JS script
 * Controls mobile navigation, scroll actions, and form events.
 * =================================================================== */

document.addEventListener('DOMContentLoaded', function() {
  
  // Mobile menu toggle
  const menuToggle = document.getElementById('menuToggle');
  const navLinks = document.getElementById('navLinks');
  
  if (menuToggle && navLinks) {
    menuToggle.addEventListener('click', function(e) {
      e.stopPropagation();
      navLinks.classList.toggle('active');
      const icon = menuToggle.textContent;
      menuToggle.textContent = icon === '☰' ? '✕' : '☰';
    });
    
    // Close mobile menu when clicking outside
    document.addEventListener('click', function(e) {
      if (!navLinks.contains(e.target) && e.target !== menuToggle) {
        navLinks.classList.remove('active');
        menuToggle.textContent = '☰';
      }
    });
  }

  // Scroll effect on Navbar
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', function() {
    if (window.scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });

  // Footer Year Automatic Update
  const currentYear = new Date().getFullYear();
  document.querySelectorAll('.js-current-year').forEach(function(el) {
    el.textContent = currentYear;
  });

  // Contact Form Submission Mock / Handling
  const contactForm = document.getElementById('contactForm');
  if (contactForm) {
    contactForm.addEventListener('submit', function(e) {
      e.preventDefault();
      
      const submitBtn = contactForm.querySelector('input[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.value = 'Sending Message...';
      }

      const name = document.getElementById('cName')?.value || '';
      const email = document.getElementById('cEmail')?.value || '';
      const message = document.getElementById('cMessage')?.value || '';

      if (!name || !email || !message) {
        alert('Please fill out all required fields.');
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.value = 'Send Message';
        }
        return;
      }

      // Simulate API call
      setTimeout(function() {
        alert(`Thank you, ${name}! Your message has been sent successfully. We will get back to you shortly.`);
        contactForm.reset();
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.value = 'Send Message';
        }
      }, 1200);
    });
  }

});
