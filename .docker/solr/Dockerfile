ARG SOLR_TAG

FROM solr:${SOLR_TAG}

ARG SOLR_CONFIGSET_PATH

COPY --chown=solr:root ${SOLR_CONFIGSET_PATH} /opt/solr/solr-conf

CMD ["sh", "-c", "solr-precreate ${SOLR_CORE} /opt/solr/solr-conf"]