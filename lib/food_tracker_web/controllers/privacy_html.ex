defmodule FoodTrackerWeb.PrivacyHTML do
  use FoodTrackerWeb, :html

  def index(assigns) do
    ~H"""
    <div class="h-full overflow-y-auto px-4 py-6">
      <div class="container mx-auto max-w-4xl pb-8">
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "WebPage",
            "name": "Privacy Policy - Food Tracker",
            "description": "Privacy Policy for the Food Tracker application",
            "datePublished": "<%= Date.utc_today() |> Calendar.strftime("%Y-%m-%d") %>",
            "author": {
              "@type": "Organization",
              "name": "Food Tracker"
            },
            "publisher": {
              "@type": "Organization",
              "name": "Food Tracker"
            }
          }
        </script>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          Privacy Policy
        </h2>
        <p class="mb-4 text-gray-800 dark:text-gray-200">
          Last updated: {Date.utc_today() |> Calendar.strftime("%d.%m.%Y")}
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          1. Introduction
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We at Food Tracker ("we", "us", "our") respect your privacy and are committed to protecting your personal data.
          This privacy policy will inform you about how we handle your data and your privacy rights.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          2. Data We Collect
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Our application Food Tracker collects the following personal data:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Email addresses: Used for account registration, authentication, and communication</li>
          <li>Anonymous identifiers: Used to track and personalize anonymous user sessions</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We also collect the following non-personal data:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Food tracking data: Information you input about your meals and food consumption</li>
          <li>
            Usage timestamps: When your account was last active, used for anonymous account cleanup
          </li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We do not use:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Tracking technologies for marketing purposes</li>
          <li>Third-party analytics services</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          3. How We Use Your Data
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We use your email address for:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Account creation and authentication</li>
          <li>Sending password reset instructions when requested</li>
          <li>Sending email verification links</li>
          <li>Important service notifications</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We use anonymous identifiers for:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Tracking your session across visits when you don't have a registered account</li>
          <li>Preserving your food tracking data if you later decide to register</li>
          <li>Personalizing your experience as an anonymous user</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Your food tracking data is used solely to provide you with the food tracking functionality of the application.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          4. Anonymous Users
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          You can use Food Tracker without creating a registered account. Here's what you should know:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>
            When you first use the application, we create an anonymous profile identified by a cookie
          </li>
          <li>This anonymous profile allows you to track your food entries without registration</li>
          <li>
            If you later decide to register, all your existing data will be preserved and transferred to your registered account
          </li>
          <li>Anonymous user data is automatically deleted after 30 days of inactivity</li>
          <li>You can delete your anonymous data at any time by clearing your browser cookies</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          5. Legal Basis for Processing
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Under the GDPR, we process your personal data on the following legal grounds:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Contract fulfillment: Processing necessary to provide you with our service</li>
          <li>Consent: When you explicitly agree to certain data processing activities</li>
          <li>
            Legitimate interests: When processing is necessary for our legitimate business interests
          </li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          6. Data Retention
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We retain your personal data as long as necessary to provide you with our services or as required by applicable laws. You can request deletion of your registered account and associated data at any time.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          For anonymous users, we apply the following retention policies:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Anonymous user accounts are automatically deleted after 30 days of inactivity</li>
          <li>The anonymous identifier cookie expires after 30 days</li>
          <li>
            When you convert to a registered account, your anonymous data is preserved under your new registered account
          </li>
          <li>Our system runs daily checks to identify and remove inactive anonymous accounts</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          7. Your Rights
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Under the GDPR, you have the following rights regarding your personal data:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Right to access: You can request a copy of your personal data</li>
          <li>Right to rectification: You can request correction of inaccurate data</li>
          <li>Right to erasure: You can request deletion of your personal data</li>
          <li>Right to restrict processing: You can request limitation of how we use your data</li>
          <li>Right to data portability: You can request transfer of your data</li>
          <li>Right to object: You can object to certain types of processing</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          To exercise these rights, please contact us through our application or via email.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          8. Data Security
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We implement appropriate security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. These measures include encryption, secure communication protocols, and regular security assessments.
        </p>
      </div>
    </div>
    """
  end
end
