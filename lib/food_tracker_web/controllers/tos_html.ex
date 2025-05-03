defmodule FoodTrackerWeb.TosHTML do
  use FoodTrackerWeb, :html

  def index(assigns) do
    ~H"""
    <div class="h-full overflow-y-auto px-4 py-6">
      <div class="container mx-auto max-w-4xl pb-8">
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "WebPage",
            "name": "Terms of Service - Food Tracker",
            "description": "Terms of Service for the Food Tracker application",
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
          Terms of Service
        </h2>
        <p class="mb-4 text-gray-800 dark:text-gray-200">
          Last updated: {Date.utc_today() |> Calendar.strftime("%d.%m.%Y")}
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          1. Introduction and Nature of Service
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Food Tracker is an exercise project created for educational purposes. The application is provided free of charge and without any guarantees of continued operation, availability, or maintenance.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          By using this application, you acknowledge and accept that:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>The service may be discontinued at any time without prior notice</li>
          <li>Features may change or be removed without prior notice</li>
          <li>There is no guarantee of data persistence or backup</li>
          <li>Support or maintenance is provided on a best-effort basis, if at all</li>
          <li>The application may contain bugs or errors as it is an educational project</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          2. Acceptance of Terms
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          By accessing or using the Food Tracker application ("the Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the Service.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          3. Description of Service
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Food Tracker is a web application designed to help users track their food consumption. The Service allows users to create accounts, record meals, and track their eating habits over time.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          As this is an exercise project, you are free to sign up and use it at no cost, but we do not promise continued operation, technical support, or any kind of services beyond what is currently available.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          4. User Accounts
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          To use the Service, you can either create a registered account or use it anonymously.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          When using a registered account, you need to provide a valid email address and secure password. You are responsible for:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Maintaining the confidentiality of your account credentials</li>
          <li>All activities that occur under your account</li>
          <li>
            Backing up any data you consider important, as we do not guarantee data preservation
          </li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          When using the Service anonymously:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Your session is identified by a cookie with a unique identifier</li>
          <li>Your data will be retained for a maximum of 30 days of inactivity</li>
          <li>You can convert to a registered account at any time to preserve your data</li>
          <li>Anonymous accounts may be deleted during routine maintenance</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          5. User Content
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          You retain ownership of any content you submit to the Service. By using the Service, you grant us a non-exclusive license to use, store, and process your content solely for the purpose of providing the Service.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          Given the educational nature of this project, we strongly advise against storing sensitive personal information in the application.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          6. Acceptable Use
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          You agree not to use the Service to:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Violate any applicable laws or regulations</li>
          <li>Infringe on the rights of others</li>
          <li>Distribute malware or harmful code</li>
          <li>Attempt to gain unauthorized access to the Service or its systems</li>
          <li>Engage in activities that could disrupt or impair the Service</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          7. Limitation of Liability and Disclaimer of Warranties
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT ANY WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
        </p>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          For anonymous users, we additionally make no warranty that:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>Your data will be preserved beyond the 30-day inactivity period</li>
          <li>The anonymous user functionality will remain available indefinitely</li>
          <li>Your anonymous user session will be accessible across different devices or browsers</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          As an exercise project, we make no warranty that:
        </p>
        <ul class="list-disc pl-8 mb-4 text-gray-700 dark:text-gray-300">
          <li>The Service will meet your requirements or expectations</li>
          <li>The Service will be uninterrupted, timely, secure, or error-free</li>
          <li>Any errors in the software will be corrected</li>
          <li>The results obtained from using the Service will be accurate or reliable</li>
          <li>The quality of the Service will meet your expectations</li>
        </ul>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the Service.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          8. Changes to Terms
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We may modify these Terms of Service at any time without notice. Your continued use of the Service after such modifications constitutes your acceptance of the updated terms.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          9. Termination
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          We reserve the right to suspend or terminate the Service or your access to it at any time, for any reason, and without prior notice. Given the exercise nature of this project, the Service may be discontinued entirely without warning.
        </p>

        <h2 class="text-2xl font-semibold mt-6 mb-3 text-gray-800 dark:text-gray-100">
          10. Contact
        </h2>
        <p class="mb-4 text-gray-700 dark:text-gray-300">
          As this is an exercise project, support is limited or unavailable. For educational purposes only, you may attempt to contact us through the application with questions about these Terms of Service.
        </p>
      </div>
    </div>
    """
  end
end
