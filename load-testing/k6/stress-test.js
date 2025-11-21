import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Stress test - gradually increase load to find breaking point
export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp up to 50 users
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 150 },  // Ramp up to 150 users
    { duration: '5m', target: 150 },  // Stay at 150 users
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],  // 95% of requests should be below 1s under stress
    http_req_failed: ['rate<0.10'],     // Allow up to 10% error rate under stress
    errors: ['rate<0.10'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://sample-app.dev.svc.cluster.local';

export default function () {
  const responses = http.batch([
    ['GET', `${BASE_URL}/`],
    ['GET', `${BASE_URL}/health`],
    ['GET', `${BASE_URL}/ready`],
    ['GET', `${BASE_URL}/api/users`],
  ]);

  responses.forEach((res) => {
    check(res, {
      'status is 2xx': (r) => r.status >= 200 && r.status < 300,
    }) || errorRate.add(1);
  });

  sleep(0.5);
}

export function handleSummary(data) {
  return {
    'stdout': JSON.stringify(data, null, 2),
  };
}
