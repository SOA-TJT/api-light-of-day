# frozen_string_literal: true

require 'aws-sdk-ses'

module LightofDay
  module Messaging
    # SNS messaging
    class Email
      def initialize
        # ses init
        @sender = 'jerry.ho@iss.nthu.edu.tw'
        # Replace us-west-2 with the AWS Region you're using for Amazon SES.
        @ses = Aws::SES::Client.new(region: 'us-east-2')
        @content = ''
        @lightofday
      end

      def subscribe(email)
        recipient = email
        # Try to verify email address.
        begin
          @ses.verify_email_identity(
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

      def replace_tag(content, tag, target)
        content.gsub!("{{#{tag}}}", target)
      end

      def generate_email
        content = "
        <div style='width: 800px;height: 600px;margin: auto;text-align: center; '>
          <div style='width: 100%;height: 100%;background-image: url(\"#{@lightofday.urls}\");background-position: center;background-repeat: no-repeat;background-size: cover;'></div>
        </div>
        <h1 style='word-wrap: break-word; font-weight: normal;'><strong>#{@lightofday.inspiration.quote}</strong></h1>
        <p style='line-height: 140%; font-size: 14px;'><strong><u>- #{@lightofday.inspiration.author}</u></strong></p>
        <p style='line-height: 140%; font-size: 14px;'><strong><u>Photo Creator:#{@lightofday.creator_name}</u></strong></p>
        <p style='line-height: 140%; font-size: 14px;'><strong>Visit our website </strong></p>
        <p style='line-height: 140%; font-size: 14px;'><a rel='noopener' href='https://lightofdayapp.herokuapp.com' target='_blank'>https://lightofdayapp.herokuapp.com</a></p>"
        @content = content
      end

      def generate_lightofday
        @lightofday = LightofDay::Unsplash::ViewMapper
                      .new(LightofDay::App.config.UNSPLASH_SECRETS_KEY,
                           'wallspaper').find_a_photo
        puts @lightofday
      end

      def send_all
        Concurrent::Promise
          .execute { generate_lightofday }
          .then { generate_email }
          .then { list_all_email }
      end

      def list_all_email
        # Get up to 1000 identities
        ids = @ses.list_identities({
          identity_type: "EmailAddress"
        })

        ids.identities.each do |email|
          attrs = @ses.get_identity_verification_attributes({
            identities: [email]
          })

          status = attrs.verification_attributes[email].verification_status
          # Display email addresses that have been verified
          if status == 'Success'
            send(email, @content) unless email == @sender
          end
        end
      end

      def send(email, body)
        puts body
        recipient = email

        # The subject line for the email.
        subject = 'Light Of Day'

        # The HTML body of the email.
        htmlbody = body

        # The email body for recipients with non-HTML email clients.
        textbody = 'This email was sent with Amazon SES using the AWS SDK for Ruby.'

        # Specify the text encoding scheme.
        encoding = 'UTF-8'
        # Try to send the email.
        begin
          # Provide the contents of the email.
          @ses.send_email(
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
