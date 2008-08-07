require File.dirname(__FILE__) + '/../test_helper'

class EmailConfirmationMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_signup
    @expected.subject = 'EmailConfirmationMailer#signup'
    @expected.body    = read_fixture('signup')
    @expected.date    = Time.now

    assert_equal @expected.encoded, EmailConfirmationMailer.create_signup(@expected.date).encoded
  end

  def test_confirm
    @expected.subject = 'EmailConfirmationMailer#confirm'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, EmailConfirmationMailer.create_confirm(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/email_confirmation_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
