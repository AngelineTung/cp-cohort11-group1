echo "--- 🗑️ DELETING STUCK ECS SERVICE ---"

# 1. Set the names (based on your logs)
CLUSTER_NAME="grp1-ce11-dev-iot-cluster"
SERVICE_NAME="dev-iot-service"

# 2. Force delete the service
aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --desired-count 0 2>/dev/null
aws ecs delete-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --force

echo "⏳ Waiting 20 seconds for AWS to fully remove it..."
sleep 20

echo "✅ Service deleted. You can re-run the pipeline now."