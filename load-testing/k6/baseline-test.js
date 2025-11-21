import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Test configuration for baseline load test
export const options = {
  stages: [
    { duration: '1m', target: 10 },  // Ramp up to 10 users
    { duration: '3m', target: 10 },  // Stay at 10 users
    { duration: '1m', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.05'],     // Error rate should be less than 5%
    errors: ['rate<0.05'],
  },
};

// Base URL - can be overridden by environment variable
const BASE_URL = __ENV.BASE_URL || 'http://sample-app.dev.svc.cluster.local';

export default function () {
  // Test root endpoint
  let res = http.get(`${BASE_URL}/`);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response has service': (r) => r.json('service') !== undefined,
  }) || errorRate.add(1);

  sleep(1);

  // Test health endpoint
  res = http.get(`${BASE_URL}/health`);
  check(res, {
    'health check is 200': (r) => r.status === 200,
    'health status is healthy': (r) => r.json('status') === 'healthy',
  }) || errorRate.add(1);

  sleep(1);

  // Test API endpoint
  res = http.get(`${BASE_URL}/api/users`);
  check(res, {
    'api status is 200': (r) => r.status === 200,
    'api has users array': (r) => Array.isArray(r.json('users')),
  }) || errorRate.add(1);

  sleep(1);
}

export function handleSummary(data) {
  return {
    'stdout': JSON.stringify(data, null, 2),
  };
}
