resource "datadog_logs_custom_pipeline" "AdService_Pipeline" {
  filter {
    query = "service:adservice"
  }
  name       = "AdService Application"
  is_enabled = true
  processor {
    grok_parser {
      samples = ["Ad seen. Advertiser 'Fruit Tree'" , "Advertiser 'Good Food' on "]
      source  = "message"
      grok {
        support_rules = ""
        match_rules = "impression Ad\\s+%%{word:state}\\.\\s+Advertiser\\s+'%%{data:advertiser}'\ntoggle_state Advertiser\\s+'%%{data:advertiser}'\\s+%%{notSpace:state}"
      }
      name       = "Advertiser state"
      is_enabled = true
    }
  }
  processor {
    attribute_remapper {
      name = "advertiser"
      source_type = "attribute"
      sources = ["advertiser"]
      target_type = "tag"
      target = "advertiser"
      is_enabled = true
    }
 }
  processor {
    attribute_remapper {
      name = "state"
      source_type = "attribute"
      sources = ["state"]
      target_type = "tag"
      target = "state"
      is_enabled = true
    }
 }
}