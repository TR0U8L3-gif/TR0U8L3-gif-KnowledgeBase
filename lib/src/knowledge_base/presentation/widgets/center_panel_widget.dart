import 'package:shadcn_flutter/shadcn_flutter.dart';

class CenterPanelWidget extends StatelessWidget {
  const CenterPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Breadcrumb(
            separator: Breadcrumb.arrowSeparator,
            children: [
              TextButton(
                onPressed: () {},
                density: ButtonDensity.compact,
                child: const Text('Home'),
              ),
              TextButton(
                onPressed: () {},
                density: ButtonDensity.compact,
                child: const Text('API Documentation'),
              ),
              const Text('Authentication API'),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Authentication API').h1(),
                const Gap(8),
                const Text('Last updated: January 4, 2026').muted().small(),
                const Gap(24),
                const Text(
                  'Authentication endpoints including login, refresh, logout and user information retrieval.',
                ).lead(),
                const Gap(32),
                const Text('Overview').h2(),
                const Gap(12),
                const Text(
                  'The Authentication API provides a comprehensive set of endpoints for managing user authentication and sessions. '
                  'It supports JWT-based authentication with refresh token rotation and secure session management.',
                ).p(),
                const Gap(16),
                const Text(
                  'All endpoints require HTTPS and return JSON responses. Authentication tokens are issued as HTTP-only cookies '
                  'for enhanced security.',
                ).p(),
                const Gap(32),
                const Text('Authentication Flow').h2(),
                const Gap(12),
                const Text('Initial Login').h3(),
                const Gap(8),
                const Text(
                  '1. User submits credentials to /api/auth/login\n'
                  '2. Server validates credentials\n'
                  '3. Server issues access token (15min) and refresh token (7 days)\n'
                  '4. Tokens stored as HTTP-only cookies',
                ).p(),
                const Gap(24),
                const Text('Token Refresh').h3(),
                const Gap(8),
                const Text(
                  'Access tokens expire after 15 minutes. The client should monitor the token expiration '
                  'and request a new access token using the refresh token before expiration.',
                ).p(),
                const Gap(32),
                const Text('Endpoints').h2(),
                const Gap(12),
                const Text('POST /api/auth/login').h3(),
                const Gap(8),
                const Text('Authenticate a user and receive tokens.').p(),
                const Gap(8),
                OutlinedContainer(
                  child: const Text(
                    '{\n'
                    '  "email": "user@example.com",\n'
                    '  "password": "secure_password"\n'
                    '}',
                  ).p(),
                ),
                const Gap(24),
                const Text('POST /api/auth/refresh').h3(),
                const Gap(8),
                const Text('Refresh an expired access token.').p(),
                const Gap(24),
                const Text('POST /api/auth/logout').h3(),
                const Gap(8),
                const Text(
                  'Invalidate the current session and clear authentication cookies.',
                ).p(),
                const Gap(24),
                const Text('GET /api/auth/me').h3(),
                const Gap(8),
                const Text(
                  'Retrieve the currently authenticated user information.',
                ).p(),
                const Gap(32),
                const Text('Security Considerations').h2(),
                const Gap(12),
                const Text('Token Storage').h4(),
                const Gap(8),
                const Text(
                  'Tokens are stored as HTTP-only cookies to prevent XSS attacks. The SameSite attribute '
                  'is set to Strict to prevent CSRF attacks.',
                ).p(),
                const Gap(16),
                const Text('Rate Limiting').h4(),
                const Gap(8),
                const Text(
                  'Login attempts are rate-limited to 5 attempts per 15 minutes per IP address. '
                  'After exceeding the limit, the IP is temporarily blocked.',
                ).p(),
                const Gap(16),
                const Text('Password Requirements').h4(),
                const Gap(8),
                const Text(
                  'Passwords must be at least 12 characters long and include uppercase, lowercase, '
                  'numbers, and special characters.',
                ).p(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
