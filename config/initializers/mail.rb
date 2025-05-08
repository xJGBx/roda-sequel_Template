require "mailersend-ruby"

MS_CLIENT = Mailersend::Client.new(ENV["MAILER_SEND_KEY"])

def send_checkout_email(user)
  Mail.deliver do
    from "your_email@example.com" # Replace with your sender email address
    to user_email
    subject "Order Confirmation"
    body "Thank you for your order!"
  end
end

def send_seller_order_email(seller, user)
  # Intialize the email class
  ms_email = Mailersend::Email.new(MS_CLIENT)

  # Add parameters
  ms_email.add_recipients("email" => seller.email, "name" => seller.name)
  ms_email.add_from("email" => "test@trial-k68zxl219k94j905.mlsender.net", "name" => "selly.ee")
  ms_email.add_subject("You have recieved an Order")
  ms_email.add_text("You have received an order from #{user.username}")

  # Send the email
  ms_email.send
end

def send_user_order_status_email(seller, customer, order_item, product)
  # Intialize the email class
  ms_email = Mailersend::Email.new(MS_CLIENT)

  # Add parameters
  ms_email.add_recipients("email" => customer.email, "name" => customer.username)
  ms_email.add_from("email" => "test@trial-k68zxl219k94j905.mlsender.net", "name" => "Selly.com")
  ms_email.add_subject("The order of #{product.name} ; status has changed to #{order_item.status}")
  ms_email.add_text("The Order containing #{order_item.quantity} unit/units of #{product.name}, has had its status changed to #{order_item.status} by #{seller.name}  ")

  # Send the email
  ms_email.send
rescue StandardError => e
  puts "Error sending email: #{e.message}"
end
