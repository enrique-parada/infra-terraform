resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    {
      "Name" = var.bucket_name
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Website estático simple
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Política para permitir GET público (para prueba)
data "aws_iam_policy_document" "public_read" {
  statement {
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.public_read.json
}

