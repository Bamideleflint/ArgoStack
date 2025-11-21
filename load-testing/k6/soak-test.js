import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Soak test - sustained load over extended period to find memory leaks
export const options = {
  stages: [
    { duration: '2m', target: 30 },    // Ramp up to 30 users
    { duration: '30m', target: 30 },   // Stay at 30 users for 30 minutes
    { duration: '2m', target: 0 },     // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<600'],   // 95% of requests should be below 600ms
    http_req_failed: ['rate<0.05'],     // Error rate should be less than 5%
    errors: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://sample-app.dev.svc.cluster.local';

export default function () {
  // Simulate realistic user behavior
  let res = http.get(`${BASE_URL}/`);
  check(res, { 'home status is 200': (r) => r.status === 200 }) || errorRate.add(1);
  sleep(2);

  res = http.get(`${BASE_URL}/api/users`);
  check(res, { 'api status is 200': (r) => r.status === 200 }) || errorRate.add(1);
  sleep(3);

  res = http.get(`${BASE_URL}/health`);
  check(res, { 'health status is 200': (r) => r.status === 200 }) || errorRate.add(1);
  sleep(2);
}

export function handleSummary(data) {
  return {
    'stdout': JSON.stringify(data, null, 2),
  };
}
