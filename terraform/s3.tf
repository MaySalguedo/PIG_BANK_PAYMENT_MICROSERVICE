data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "catalog_uploads" {
  bucket = "pig-bank-catalog-uploads-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_notification" "catalog_notification" {
  bucket = aws_s3_bucket.catalog_uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sync_catalog.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync_catalog.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.catalog_uploads.arn
}