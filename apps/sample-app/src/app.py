
"""
Sample Flask Application with Prometheus Metrics
This application demonstrates best practices for observability
"""

from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from prometheus_client import CONTENT_TYPE_LATEST
import time
import random
import logging
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Prometheus Metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

ACTIVE_REQUESTS = Gauge(
    'http_requests_active',
    'Number of active HTTP requests'
)

BUSINESS_METRICS = Counter(
    'business_operations_total',
    'Total business operations',
    ['operation', 'status']
)

APP_INFO = Gauge(
    'app_info',
    'Application information',
    ['version', 'environment']
)

# Set application info
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
APP_INFO.labels(version=APP_VERSION, environment=ENVIRONMENT).set(1)


# Middleware for metrics
@app.before_request
def before_request():
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()


@app.after_request
def after_request(response):
    # Ensure we always decrement the active requests counter
    try:
        ACTIVE_REQUESTS.dec()
    except Exception as e:
        logger.warning(f"Failed to decrement active requests counter: {e}")
    
    # Record request metrics
    try:
        request_duration = time.time() - request.start_time
        
        # Use request.endpoint or fallback to request path
        endpoint = request.endpoint if request.endpoint else request.path if request.path else 'unknown'
        method = request.method if request.method else 'unknown'
        
        # Record request duration
        REQUEST_DURATION.labels(
            method=method,
            endpoint=endpoint
        ).observe(request_duration)
        
        # Record request count
        REQUEST_COUNT.labels(
            method=method,
            endpoint=endpoint,
            status=response.status_code
        ).inc()
    except Exception as e:
        logger.warning(f"Failed to record request metrics: {e}")
    
    return response


# Health endpoints
@app.route('/health')
def health():
    """Liveness probe endpoint"""
    return jsonify({'status': 'healthy', 'version': APP_VERSION}), 200


@app.route('/ready')
def ready():
    """Readiness probe endpoint"""
    # Add actual readiness checks here (database, cache, etc.)
    try:
        # Simulate dependency check
        is_ready = True
        if is_ready:
            return jsonify({'status': 'ready', 'checks': {'database': 'ok'}}), 200
        else:
            return jsonify({'status': 'not ready'}), 503
    except Exception as e:
        logger.error(f"Readiness check failed: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 503


# Metrics endpoint
@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    try:
        return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}
    except Exception as e:
        logger.error(f"Failed to generate metrics: {e}")
        return jsonify({'error': 'Failed to generate metrics'}), 500


# Application endpoints
@app.route('/')
def index():
    """Root endpoint"""
    logger.info("Root endpoint accessed")
    return jsonify({
        'service': 'Sample Application',
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'status': 'production-ready',
        'message': 'End-to-end workflow test successful!',
        'endpoints': {
            'health': '/health',
            'ready': '/ready',
            'metrics': '/metrics',
            'api': '/api/*'
        }
    }), 200


@app.route('/api/users', methods=['GET'])
def get_users():
    """Get users endpoint"""
    try:
        # Simulate processing time
        time.sleep(random.uniform(0.01, 0.1))
        
        users = [
            {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
            {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
            {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
        ]
        
        BUSINESS_METRICS.labels(operation='get_users', status='success').inc()
        logger.info(f"Retrieved {len(users)} users")
        
        return jsonify({'users': users, 'count': len(users)}), 200
    except Exception as e:
        BUSINESS_METRICS.labels(operation='get_users', status='error').inc()
        logger.error(f"Error getting users: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get specific user endpoint"""
    try:
        # Simulate database lookup
        time.sleep(random.uniform(0.01, 0.05))
        
        if user_id > 100:
            BUSINESS_METRICS.labels(operation='get_user', status='not_found').inc()
            return jsonify({'error': 'User not found'}), 404
        
        user = {
            'id': user_id,
            'name': f'User {user_id}',
            'email': f'user{user_id}@example.com'
        }
        
        BUSINESS_METRICS.labels(operation='get_user', status='success').inc()
        logger.info(f"Retrieved user {user_id}")
        
        return jsonify(user), 200
    except Exception as e:
        BUSINESS_METRICS.labels(operation='get_user', status='error').inc()
        logger.error(f"Error getting user {user_id}: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/users', methods=['POST'])
def create_user():
    """Create user endpoint"""
    try:
        data = request.get_json()
        
        # Validate input
        if not data or 'name' not in data or 'email' not in data:
            BUSINESS_METRICS.labels(operation='create_user', status='validation_error').inc()
            return jsonify({'error': 'Invalid input'}), 400
        
        # Simulate processing
        time.sleep(random.uniform(0.05, 0.15))
        
        new_user = {
            'id': random.randint(1, 1000),
            'name': data['name'],
            'email': data['email']
        }
        
        BUSINESS_METRICS.labels(operation='create_user', status='success').inc()
        logger.info(f"Created user: {new_user['id']}")
        
        return jsonify(new_user), 201
    except Exception as e:
        BUSINESS_METRICS.labels(operation='create_user', status='error').inc()
        logger.error(f"Error creating user: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/simulate-error')
def simulate_error():
    """Endpoint to simulate errors for testing"""
    error_type = request.args.get('type', 'generic')
    
    if error_type == '500':
        BUSINESS_METRICS.labels(operation='simulate_error', status='error').inc()
        return jsonify({'error': 'Internal server error'}), 500
    elif error_type == '404':
        return jsonify({'error': 'Not found'}), 404
    elif error_type == 'slow':
        # Simulate slow request
        time.sleep(2)
        return jsonify({'message': 'Slow response'}), 200
    else:
        raise Exception("Simulated exception")


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Resource not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    logger.info(f"Starting application on port {port}")
    logger.info(f"Version: {APP_VERSION}, Environment: {ENVIRONMENT}")
    app.run(host='0.0.0.0', port=port, debug=False)
