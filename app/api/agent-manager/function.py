# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
"""Agent Manager"""

# agent-manager/function.py
import json
import logging
import os
import boto3
from dotenv import load_dotenv
from lib.utils import create_api_response
from lib.dynamodb import DynamoDBService
from lib.s3 import S3Service
from lib.models import DocumentAnalysisRequest
from lib.document_analyzer import DocumentAnalyzer

# Configure logging
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

def initialize_services():
    """Initialize services at module level"""
    if not os.environ.get('AWS_S3_BUCKET_NAME'):
        raise ValueError("AWS_S3_BUCKET_NAME environment variable is not set")

    bedrock_client = boto3.client(
        "bedrock-runtime",
        region_name="us-east-1",
    )
    s3_service = S3Service()
    db_service = DynamoDBService()

    return {
        'bedrock_client': bedrock_client,
        's3_service': s3_service,
        'db_service': db_service
    }

# Initialize services at module level
SERVICES = initialize_services()

# Initialize analyzer at module level
MANAGER = DocumentAnalyzer(SERVICES, LOGGER)

async def analyze_document(event, context):
    """POST method for /analyze-document"""
    LOGGER.info("Received analyze document request")

    try:
        if event.get('httpMethod') == 'OPTIONS':
            return create_api_response(200, {})

        # Parse request body
        body = event.get('body')
        if not body:
            return create_api_response(400, {'detail': 'No body found in request'})

        if isinstance(body, str):
            body = json.loads(body)

        request = DocumentAnalysisRequest(**body)

        # Process document
        result = await MANAGER.analyze_document(request.image_base64)
        return create_api_response(200, result)

    except ValueError as ve:
        LOGGER.error("Validation error: %s", str(ve))
        return create_api_response(400, {'detail': str(ve)})
    except Exception as e: # pylint: disable=broad-except
        LOGGER.error("Error: %s", str(e))
        return create_api_response(500, {'detail': str(e)})

async def get_verifications(event, context):
    """GET method for /verifications"""
    LOGGER.info("Received get verifications request")

    try:
        if event.get('httpMethod') == 'OPTIONS':
            return create_api_response(200, {})

        results = await MANAGER.get_verifications()
        return create_api_response(200, results)

    except Exception as e: # pylint: disable=broad-except
        LOGGER.error("Error: %s", str(e))
        return create_api_response(500, {'detail': str(e)})

async def get_verification(event, context):
    """GET method for /verifications/{verification_id}"""
    LOGGER.info("Received get verification request")

    try:
        if event.get('httpMethod') == 'OPTIONS':
            return create_api_response(200, {})

        verification_id = event['pathParameters']['verification_id']
        result = await MANAGER.get_verification(verification_id)
        return create_api_response(200, result)

    except ValueError as ve:
        return create_api_response(404, {'detail': str(ve)})
    except Exception as e: # pylint: disable=broad-except
        LOGGER.error("Error: %s", str(e))
        return create_api_response(500, {'detail': str(e)})
