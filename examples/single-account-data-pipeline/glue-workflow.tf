resource "aws_glue_workflow" "this" {
  name = "${local.project-name}-${local.module-name}-workflow"
}

resource "aws_glue_trigger" "ingestion-crawler" {
  name          = "${local.project-name}-${local.module-name}-ingestion-crawler"
  type          = "ON_DEMAND"
  workflow_name = aws_glue_workflow.this.name

  actions {
    crawler_name = module.ingestion-crawler.name
  }
}

resource "aws_glue_trigger" "transformation-job" {
  name          = "${local.project-name}-${local.module-name}-transformation-job"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.this.name

  actions {
    job_name = module.transformation-glue-job.name
  }

  predicate {
    conditions {
      crawler_name  = module.ingestion-crawler.name
      crawl_state = "SUCCEEDED"
    }
  }
}

resource "aws_glue_trigger" "transformation-crawler" {
  name          = "${local.project-name}-${local.module-name}-transformation-crawler"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.this.name

  actions {
    crawler_name = module.transformation-crawler.name
  }

  predicate {
    conditions {
      job_name = module.transformation-glue-job.name
      state    = "SUCCEEDED"
    }
  }
}