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
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We also collect the following non-personal data:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Food tracking data: Information you input about your meals and food consumption</li>
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
          Your food tracking data is used solely to provide you with the food tracking functionality of the application.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          4. Legal Basis for Processing
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
          5. Data Retention
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We retain your personal data as long as necessary to provide you with our services or as required by applicable laws. You can request deletion of your account and associated data at any time.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          6. Your Rights
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
          7. Data Security
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We implement appropriate security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. These measures include encryption, secure communication protocols, and regular security assessments.
        </p>
      </div>
    </div>
    """
  end
end
