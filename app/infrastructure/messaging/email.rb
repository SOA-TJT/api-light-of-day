# frozen_string_literal: true

require 'aws-sdk-ses'

module LightofDay
  module Messaging
    # SNS messaging
    class Email
      def initialize
        # ses init
        @sender = 'jerryjp3914@gmail.com'
      end

      def subscribe(email)
        recipient = email
        # Replace us-west-2 with the AWS Region you're using for Amazon SES.
        ses = Aws::SES::Client.new(region: 'us-east-2')

        # Try to verify email address.
        begin
          ses.verify_email_identity(
            {
              email_address: recipient
            }
          )

          puts "Email sent to #{recipient}"

        # If something goes wrong, display an error message.
        rescue Aws::SES::Errors::ServiceError => e
          puts "Email not sent. Error message: #{e}"
        end
      end

      def send(email, body)
        recipient = email

        # The subject line for the email.
        subject = 'Light Of Day'

        # The HTML body of the email.
        htmlbody = body

        # The email body for recipients with non-HTML email clients.
        textbody = 'This email was sent with Amazon SES using the AWS SDK for Ruby.'

        # Specify the text encoding scheme.
        encoding = 'UTF-8'

        # Replace us-west-2 with the AWS Region you're using for Amazon SES.
        ses = Aws::SES::Client.new(region: 'us-east-2')

        # Try to send the email.
        begin
          # Provide the contents of the email.
          ses.send_email(
            destination: {
              to_addresses: [
                recipient
              ]
            },
            message: {
              body: {
                html: {
                  charset: encoding,
                  data: htmlbody
                },
                text: {
                  charset: encoding,
                  data: textbody
                }
              },
              subject: {
                charset: encoding,
                data: subject
              }
            },
            source: @sender
            # Uncomment the following line to use a configuration set.
            # configuration_set_name: configsetname,
          )

          puts "Email sent to #{recipient}"

        # If something goes wrong, display an error message.
        rescue Aws::SES::Errors::ServiceError => e
          puts "Email not sent. Error message: #{e}"
        end
      end
    end
  end
end
