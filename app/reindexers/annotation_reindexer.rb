class AnnotationReindexer < ReindexerObserver
  observe :annotation

  def consequences annotation
    c=[]
    c = c | annotation.annotatable if annotation.annotatable.respond_to?(:reindexing_consequences)
    c << annotation.annotatable if annotation.annotatable.respond_to?(:solr_save)
    c
  end
  
end