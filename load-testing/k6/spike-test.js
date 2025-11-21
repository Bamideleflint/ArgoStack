import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Spike test - sudden traffic surge
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Normal load
    { duration: '1m', target: 200 },   // Sudden spike to 200 users
    { duration: '3m', target: 200 },   // Sustain spike
    { duration: '30s', target: 10 },   // Return to normal
    { duration: '1m', target: 10 },    // Stay at normal
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],  // Allow 2s during spike
    http_req_failed: ['rate<0.15'],     // Allow 15% errors during spike
    errors: ['rate<0.15'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://sample-app.dev.svc.cluster.local';

export default function () {
  const endpoints = [
    `${BASE_URL}/`,
    `${BASE_URL}/health`,
    `${BASE_URL}/api/users`,
  ];

  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  const res = http.get(endpoint);

  check(res, {
    'status is 2xx': (r) => r.status >= 200 && r.status < 300,
  }) || errorRate.add(1);

  sleep(0.3);
}

export function handleSummary(data) {
  return {
    'stdout': JSON.stringify(data, null, 2),
  };
}
