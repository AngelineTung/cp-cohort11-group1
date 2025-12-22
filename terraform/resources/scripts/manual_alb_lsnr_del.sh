# 1. Get the Load Balancer ARN
ALB_ARN=$(aws elbv2 describe-load-balancers --names grp1-ce11-dev-iot-alb --query "LoadBalancers[0].LoadBalancerArn" --output text 2>/dev/null)

if [ "$ALB_ARN" != "None" ] && [ ! -z "$ALB_ARN" ]; then
  echo "Found ALB: $ALB_ARN"
  
  # 2. Find and Delete Listeners (The Key Fix)
  echo "   🔍 Finding Listeners..."
  LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn "$ALB_ARN" --query "Listeners[*].ListenerArn" --output text)
  
  if [ -z "$LISTENER_ARNS" ] || [ "$LISTENER_ARNS" == "None" ]; then
    echo "   ✅ No listeners found."
  else
    for ARN in $LISTENER_ARNS; do
       echo "   🗑️ Deleting Listener: $ARN"
       aws elbv2 delete-listener --listener-arn "$ARN"
    done
  fi

  # 3. Delete the ALB
  echo "   🗑️ Deleting Load Balancer..."
  aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN"
  sleep 10
fi

# 4. Delete the stuck Target Groups
echo "--- 🧹 CLEANING UP TARGET GROUPS ---"
aws elbv2 describe-target-groups --names grp1-ce11-dev-iot-graf-tg --query "TargetGroups[0].TargetGroupArn" --output text | xargs -I {} aws elbv2 delete-target-group --target-group-arn {} 2>/dev/null
aws elbv2 describe-target-groups --names grp1-ce11-dev-iot-prom-tg --query "TargetGroups[0].TargetGroupArn" --output text | xargs -I {} aws elbv2 delete-target-group --target-group-arn {} 2>/dev/null

echo "✅ DONE. You can re-run the pipeline now."