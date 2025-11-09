#!/usr/bin/env bash
#
# Test LiteLLM Vision Routing
#
# This script tests the automatic routing of vision requests to vision-capable models.
# It sends requests with and without images to verify the routing behavior.
#

set -e

# Color codes
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

LITELLM_URL="${LITELLM_URL:-http://0.0.0.0:4000}"

# Check if LITELLM_MASTER_KEY is set
if [ -z "$LITELLM_MASTER_KEY" ]; then
  echo -e "${RED}Error: LITELLM_MASTER_KEY environment variable is not set${NC}"
  echo "Please set it with: export LITELLM_MASTER_KEY=\"sk-<your-key>\""
  exit 1
fi

# Check if LiteLLM proxy is running
echo -e "${BLUE}Checking if LiteLLM proxy is running...${NC}"
if ! curl -s "${LITELLM_URL}/health" > /dev/null 2>&1; then
  echo -e "${RED}Error: LiteLLM proxy is not running at ${LITELLM_URL}${NC}"
  echo "Start it with: litellm-start"
  exit 1
fi
echo -e "${GREEN}✓ LiteLLM proxy is running${NC}\n"

# Test 1: Request without image to non-vision model (should not route)
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test 1: Text-only request (no routing expected)${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Model: zhipuai/glm-4.6 (non-vision)"
echo "Content: Text only"
echo ""

RESPONSE1=$(curl -s -X POST "${LITELLM_URL}/v1/chat/completions" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "zhipuai/glm-4.6",
    "messages": [
      {
        "role": "user",
        "content": "Say hello in one word"
      }
    ],
    "max_tokens": 10
  }')

echo "Response:"
echo "$RESPONSE1" | jq .
echo ""

# Test 2: Request with image to non-vision model (should route to vision model)
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test 2: Image request to non-vision model (routing expected)${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Model: zhipuai/glm-4.6 (non-vision)"
echo "Content: Text + image_url"
echo "Expected: Auto-route to copilot/gpt-4o"
echo ""

# Sample image URL (a simple 1x1 pixel PNG)
IMAGE_URL="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

RESPONSE2=$(curl -s -X POST "${LITELLM_URL}/v1/chat/completions" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"zhipuai/glm-4.6\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": [
          {
            \"type\": \"text\",
            \"text\": \"Describe this image in one word\"
          },
          {
            \"type\": \"image_url\",
            \"image_url\": {
              \"url\": \"${IMAGE_URL}\"
            }
          }
        ]
      }
    ],
    \"max_tokens\": 10
  }")

echo "Response:"
echo "$RESPONSE2" | jq .
echo ""

# Check if routing occurred by looking at metadata
if echo "$RESPONSE2" | jq -e '.metadata.vision_router' > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Vision routing metadata found!${NC}"
  echo "$RESPONSE2" | jq '.metadata.vision_router'
else
  echo -e "${YELLOW}⚠ No vision routing metadata (check logs for routing info)${NC}"
fi
echo ""

# Test 3: Request with image to vision-capable model (should not route)
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test 3: Image request to vision model (no routing expected)${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Model: copilot/gpt-4o (vision-capable)"
echo "Content: Text + image_url"
echo ""

RESPONSE3=$(curl -s -X POST "${LITELLM_URL}/v1/chat/completions" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"copilot/gpt-4o\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": [
          {
            \"type\": \"text\",
            \"text\": \"Describe this image in one word\"
          },
          {
            \"type\": \"image_url\",
            \"image_url\": {
              \"url\": \"${IMAGE_URL}\"
            }
          }
        ]
      }
    ],
    \"max_tokens\": 10
  }")

echo "Response:"
echo "$RESPONSE3" | jq .
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Check the LiteLLM logs for detailed routing information:"
echo -e "  ${GREEN}litellm-service-logs${NC}  (for service)"
echo -e "  or check stdout if running manually"
echo ""
echo "Look for log messages like:"
echo "  - 'Images detected in request for model: ...'"
echo "  - 'Routing to copilot/gpt-4o'"
echo ""
