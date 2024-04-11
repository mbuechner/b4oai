<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<!DOCTYPE xsl:stylesheet>
<!--
    Stylesheet to display responses to OAI-PMH requests with a Bootstrap 5 theme.
   
    Includes
    - Bootstrap, published under the MIT licence (see http://getbootstrap.com).
    - JQuery, published under the MIT licence (see https://jquery.com).
    - Datatable, published under the MIT licence (see https://datatables.net).
    
    Copyright (c) 2022 Michael Büchner (see https://github.com/mbuechner/b4oai)
    Copyright (c) 2015-2019 Daniel Berthereau (see https://github.com/Daniel-KM)
    Copyright (c) 2002-2015, DuraSpace. All rights reserved.
    
    Published under the BSD-like licence CeCILL-B (https://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html).
    
    Basic support (see https://www.openarchives.org/OAI/2.0/guidelines.htm):
    - rightsManifest (repository and set levels)
    - branding (repository and set levels)
    - provenance (record level)
    - rights (record level)
    - about container.
    No support (may depend on server):
    - Identify compression.
-->
<xsl:stylesheet
        xmlns:dc="http://purl.org/dc/doc:elements/1.1/"
        xmlns:oai="http://www.openarchives.org/OAI/2.0/"
        xmlns:oai_branding="http://www.openarchives.org/OAI/2.0/branding/"
        xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
        xmlns:oai_friends="http://www.openarchives.org/OAI/2.0/friends/"
        xmlns:oai_gateway="http://www.openarchives.org/OAI/2.0/gateway/"
        xmlns:oai_identifier="http://www.openarchives.org/OAI/2.0/oai-identifier"
        xmlns:oai_provenance="http://www.openarchives.org/OAI/2.0/provenance"
        xmlns:oai_rights="http://www.openarchives.org/OAI/2.0/rights/"
        xmlns:toolkit="http://oai.dlib.vt.edu/OAI/metadata/toolkit"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="oai oai_identifier oai_rights oai_friends oai_branding oai_gateway toolkit oai_provenance oai_dc dc"
        version="1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="html"/>
    <!-- Variables -->
    <!-- ============================================================================================= -->
    <xsl:param name="homepage-text" select="'DDBoai'"/>
    <xsl:param name="homepage-logo" select="'/oai/docs/logo-ddbpro.svg'"/>
    <xsl:param name="homepage-logo-text" select="''"/>
    <!-- Icons -->
    <xsl:param name="favicon" select="'../images/favicon.ico'"/>
    <xsl:param name="icon-identify" select="'bi bi-info-square'"/>
    <xsl:param name="icon-formats" select="'bi bi-layers'"/>
    <xsl:param name="icon-sets" select="'bi bi-collection'"/>
    <xsl:param name="icon-identifiers" select="'bi bi-list'"/>
    <xsl:param name="icon-records" select="'bi bi-files'"/>
    <xsl:param name="icon-getrecord" select="'bi bi-file'"/>
    <xsl:param name="icon-description" select="'bi bi-body-text'"/>
    <!-- Constants. -->
    <xsl:variable name="forbidden-characters" select="':/.()#? '"/>
    <!-- URL Encoding -->
    <!-- Characters we'll support. -->
    <xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
    <xsl:variable name="latin1">&#160;&#161;&#162;&#163;&#164;&#165;&#166;&#167;&#168;&#169;&#170;&#171;&#172;&#173;&#174;&#175;&#176;&#177;&#178;&#179;&#180;&#181;&#182;&#183;&#184;&#185;&#186;&#187;&#188;&#189;&#190;&#191;&#192;&#193;&#194;&#195;&#196;&#197;&#198;&#199;&#200;&#201;&#202;&#203;&#204;&#205;&#206;&#207;&#208;&#209;&#210;&#211;&#212;&#213;&#214;&#215;&#216;&#217;&#218;&#219;&#220;&#221;&#222;&#223;&#224;&#225;&#226;&#227;&#228;&#229;&#230;&#231;&#232;&#233;&#234;&#235;&#236;&#237;&#238;&#239;&#240;&#241;&#242;&#243;&#244;&#245;&#246;&#247;&#248;&#249;&#250;&#251;&#252;&#253;&#254;&#255;</xsl:variable>
    <!-- Characters that usually don't need to be escaped -->
    <xsl:variable name="safe">!'()*-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~</xsl:variable>
    <xsl:variable name="hex">0123456789ABCDEF</xsl:variable>
    <xsl:variable name="delimiter">
        <xsl:text>|</xsl:text>
    </xsl:variable>
    <xsl:param name="metadataFormats">
        <xsl:for-each
                select="document('../?verb=ListMetadataFormats')/oai:OAI-PMH/oai:ListMetadataFormats/oai:metadataFormat/oai:metadataPrefix/text()">
            <xsl:sort/>
            <xsl:copy-of select="."/>
            <xsl:value-of select="$delimiter"/>
        </xsl:for-each>
    </xsl:param>
    <!-- ============================================================================================= -->
    <!-- Helpers -->
    <!-- ============================================================================================= -->
    <!-- Generate a list element link for the main nav bar. -->
    <!-- ================================================== -->
    <xsl:template name="nav-link">
        <xsl:param name="text"/>
        <xsl:param name="title"/>
        <xsl:param name="icon"/>
        <xsl:param name="verb"/>
        <xsl:param name="metadataPrefix"/>
        <li class="nav-item">
            <xsl:element name="a">
                <xsl:choose>
                    <xsl:when test="/oai:OAI-PMH/oai:request/@verb = $verb">
                        <xsl:attribute name="class">nav-link active</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">nav-link</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$title != ''">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$title"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="$verb = ''">
                            <xsl:text>#</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(/oai:OAI-PMH/oai:request/text(), '?verb=', $verb)"/>
                            <xsl:if test="$metadataPrefix != ''">
                                <xsl:text>&amp;metadataPrefix=</xsl:text>
                                <xsl:value-of select="$metadataPrefix"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="$icon != ''">
                    <xsl:element name="i">
                        <xsl:attribute name="class">
                            <xsl:value-of select="concat($icon, ' ', 'text-primary')"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="$text"/>
            </xsl:element>
        </li>
    </xsl:template>
    <!-- Resumption Token -->
    <!-- ================ -->
    <xsl:template match="oai:resumptionToken">
        <div class="text-center mb-5">
            <xsl:choose>
                <xsl:when test="text() != ''">
                    <xsl:variable name="urlencodedresumptionToken">
                        <xsl:call-template name="url-encode">
                            <xsl:with-param name="str" select="text()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="@expirationDate != ''">
                            <a class="btn btn-primary" data-boundary="window" data-bs-placement="right"
                               data-bs-toggle="tooltip"
                               href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=', /oai:OAI-PMH/oai:request/@verb, '&amp;resumptionToken=', $urlencodedresumptionToken)}"
                               title="Resumption token expires at {normalize-space(translate(@expirationDate, 'TZ', ' '))}">
                                Show more
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a class="btn btn-primary"
                               href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=', /oai:OAI-PMH/oai:request/@verb, '&amp;resumptionToken=', urlencodedresumptionToken)}">
                                Show more
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <button class="btn btn-primary" disabled="disabled">Show more</button>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- Response Information Modal -->
    <!-- ========================== -->
    <xsl:template name="responseInformation">
        <xsl:param name="pathEntities"/>
        <xsl:param name="pathResumptionToken"/>
        <!-- Modal -->
        <div aria-hidden="true" aria-labelledby="reponseInfoModalLabel" class="modal fade" id="reponseInfoModal"
             tabindex="-1">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="reponseInfoModalLabel">Response Information</h5>
                        <button aria-label="Close" class="btn-close" data-bs-dismiss="modal" type="button"/>
                    </div>
                    <div class="modal-body">
                        <table class="table text-break">
                            <tbody>
                                <tr>
                                    <th scope="row" style="width:25%">Request</th>
                                    <td>
                                        <xsl:value-of select="/oai:OAI-PMH/oai:request"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row" style="width:25%">Request verb</th>
                                    <td>
                                        <xsl:value-of select="/oai:OAI-PMH/oai:request/@verb"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row" style="width:25%">Response Date</th>
                                    <td>
                                        <xsl:value-of select="substring(/oai:OAI-PMH/oai:responseDate/text(), 1, 10)"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="substring(/oai:OAI-PMH/oai:responseDate/text(), 12, 8)"/>
                                    </td>
                                </tr>
                                <xsl:if test="/oai:OAI-PMH/oai:request/@identifier">
                                    <tr>
                                        <th scope="row" style="width:25%">Identifier</th>
                                        <td>
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@identifier"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="/oai:OAI-PMH/oai:request/@set">
                                    <tr>
                                        <th scope="row" style="width:25%">Set</th>
                                        <td>
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@set"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <tr>
                                    <th scope="row" style="width:25%">Results fetched</th>
                                    <td>
                                        <xsl:call-template name="result-count">
                                            <xsl:with-param name="path" select="$pathEntities"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                                <xsl:if test="/oai:OAI-PMH/oai:request/@metadataPrefix">
                                    <tr>
                                        <th scope="row" style="width:25%">Format</th>
                                        <td>
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@metadataPrefix"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="/oai:OAI-PMH/oai:request/@from != '' or /oai:OAI-PMH/oai:request/@until != ''">
                                    <tr>
                                        <th scope="row" style="width:25%">Timespan</th>
                                        <td>
                                            <xsl:if test="/oai:OAI-PMH/oai:request/@from != ''">
                                                <xsl:text>from </xsl:text>
                                                <xsl:value-of
                                                        select="normalize-space(translate(/oai:OAI-PMH/oai:request/@from, 'TZ', ' '))"/>
                                            </xsl:if>
                                            <xsl:if test="/oai:OAI-PMH/oai:request/@until != ''">
                                                <xsl:if test="/oai:OAI-PMH/oai:request/@from != ''">
                                                    <xsl:text> </xsl:text>
                                                </xsl:if>
                                                <xsl:text>until </xsl:text>
                                                <xsl:value-of
                                                        select="normalize-space(translate(/oai:OAI-PMH/oai:request/@until, 'TZ', ' '))"/>
                                            </xsl:if>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="/oai:OAI-PMH/oai:request/@resumptionToken">
                                    <tr>
                                        <th scope="row" style="width:25%">Current Resumption Token</th>
                                        <td class="text-break">
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@resumptionToken"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="$pathResumptionToken">
                                    <tr>
                                        <th scope="row" style="width:25%">Next Resumption Token</th>
                                        <td class="text-break">
                                            <xsl:value-of select="$pathResumptionToken"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th scope="row" style="width:25%">Next Resumption Token Expiration Date</th>
                                        <td>
                                            <xsl:value-of
                                                    select="normalize-space(translate($pathResumptionToken/@expirationDate, 'TZ', ' '))"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-primary" data-bs-dismiss="modal" type="button">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- Timespan Modal -->
    <!-- ============== -->
    <xsl:template name="timespanModal">
        <!-- Modal -->
        <div aria-hidden="true" aria-labelledby="timespanModalLabel" class="modal fade" id="timespanModal"
             tabindex="-1">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="timespanModalLabel">Timespan</h5>
                        <button aria-label="Close" class="btn-close" data-bs-dismiss="modal" type="button"/>
                    </div>
                    <div class="modal-body">
                        <div class="input-group mb-3">
                            <span class=" input-group-text">from</span>
                            <input aria-label="From" class="form-control" id="timespanFromInput"
                                   style="min-width:150px;" type="date" value="{/oai:OAI-PMH/oai:request/@from}"/>
                            <span class=" input-group-text">until</span>
                            <input aria-label="Until" class="form-control" id="timespanUntilInput"
                                   style="min-width:150px;"
                                   type="date" value="{/oai:OAI-PMH/oai:request/@until}"/>
                            <button class="btn btn-primary" id="timespanSetBtn" type="submit">Set</button>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-primary" data-bs-dismiss="modal" type="button">Close</button>
                    </div>
                </div>
            </div>
        </div>

    </xsl:template>

    <!-- Result count -->
    <!-- ============ -->
    <xsl:template name="result-count">
        <xsl:param name="path"/>
        <xsl:variable name="cursor" select="$path/../oai:resumptionToken/@cursor"/>
        <xsl:variable name="count" select="count($path)"/>
        <xsl:variable name="total" select="$path/../oai:resumptionToken/@completeListSize"/>
        <xsl:choose>
            <!-- One page. -->
            <xsl:when test="not($cursor)">
                <xsl:value-of select="$count"/>
            </xsl:when>
            <!-- Not last page. -->
            <xsl:when test="normalize-space($path/../oai:resumptionToken/text()) != ''">
                <xsl:value-of select="$cursor + 1"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$cursor + $count"/>
            </xsl:when>
            <!-- Last page. -->
            <xsl:when test="$total">
                <xsl:value-of select="($total - $count) + 1"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$total"/>
            </xsl:when>
            <!-- Last page without total. -->
            <xsl:otherwise>
                <xsl:text>the last&#160;</xsl:text>
                <xsl:value-of select="$count"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$total">
            <xsl:text>&#160;of&#160;</xsl:text>
            <xsl:value-of select="$total"/>
        </xsl:if>
    </xsl:template>
    <!-- First results -->
    <!-- ============= -->
    <xsl:template name="first-result">
        <xsl:param name="path"/>
        <xsl:variable name="cursor" select="$path/../oai:resumptionToken/@cursor"/>
        <xsl:variable name="count" select="count($path)"/>
        <xsl:variable name="total" select="$path/../oai:resumptionToken/@completeListSize"/>
        <xsl:choose>
            <!-- One page. -->
            <xsl:when test="not($cursor)">
                <xsl:value-of select="0"/>
            </xsl:when>
            <!-- Not last page. -->
            <xsl:when test="normalize-space($path/../oai:resumptionToken/text()) != ''">
                <xsl:value-of select="$cursor"/>
            </xsl:when>
            <!-- Last page. -->
            <xsl:when test="$total">
                <xsl:value-of select="$total - $count"/>
            </xsl:when>
            <!-- Last page without total. -->
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- TODO Find a way to get the prefix when resumption token. -->
    <xsl:template name="metadata-prefix">
        <xsl:choose>
            <xsl:when test="/oai:OAI-PMH/oai:request/@metadataPrefix != ''">
                <xsl:value-of select="/oai:OAI-PMH/oai:request/@metadataPrefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>oai_dc</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- display-button-sets -->
    <!-- =================== -->
    <xsl:template name="display-button-sets">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="count($path) > 0">
                <xsl:variable name="metadata-prefix">
                    <xsl:call-template name="metadata-prefix"/>
                </xsl:variable>
                <button aria-expanded="false" class="btn btn-primary dropdown-toggle" data-bs-toggle="dropdown"
                        type="button">
                    <xsl:attribute name="id">
                        <xsl:text>btnGroupDrop</xsl:text>
                        <xsl:value-of select="position()"/>
                    </xsl:attribute>
                    <xsl:text>Included in&#160;</xsl:text>
                    <xsl:value-of select="count($path)"/>
                    <xsl:text>&#160;Sets</xsl:text>
                </button>
                <ul class="dropdown-menu">
                    <xsl:attribute name="aria-labelledby">
                        <xsl:text>btnGroupDrop</xsl:text>
                        <xsl:value-of select="position()"/>
                    </xsl:attribute>
                    <xsl:for-each select="$path">
                        <li>
                            <a class="dropdown-item">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/oai:OAI-PMH/oai:request/text()"/>
                                    <xsl:text>?verb=ListRecords&amp;metadataPrefix=</xsl:text>
                                    <xsl:value-of select="$metadata-prefix"/>
                                    <xsl:text>&amp;set=</xsl:text>
                                    <xsl:value-of select="text()"/>
                                </xsl:attribute>
                                <xsl:value-of select="text()"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <a class="btn btn-default disabled" href="#">
                    <xsl:text>Not in a set</xsl:text>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Authors Split -->
    <!-- ============= -->
    <xsl:template match="text()" name="authors-split">
        <xsl:param name="separator" select="';'"/>
        <xsl:param name="authors"/>
        <xsl:param name="emails" select="''"/>
        <xsl:param name="institutions" select="''"/>
        <xsl:variable name="author">
            <xsl:call-template name="split">
                <xsl:with-param name="string" select="$authors"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="email">
            <xsl:call-template name="split">
                <xsl:with-param name="string" select="$emails"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="institution">
            <xsl:call-template name="split">
                <xsl:with-param name="string" select="$institutions"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($author) > 0">
                <xsl:choose>
                    <xsl:when test="$email != ''">
                        <a href="{concat('mailto:', $email)}">
                            <xsl:value-of select="$author"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$author"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="string-length($email) > 0">
                <a href="{concat('mailto:', $email)}">
                    <xsl:value-of select="$email"/>
                </a>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="string-length($institution) > 0">
            <xsl:value-of select="concat(' (', normalize-space($institution), ')')"/>
        </xsl:if>
        <xsl:if test="$authors != '' or $emails != '' or $institutions != ''">
            <br/>
            <xsl:call-template name="authors-split">
                <xsl:with-param name="separator" select="$separator"/>
                <xsl:with-param name="authors" select="substring-after($authors, $separator)"/>
                <xsl:with-param name="emails" select="substring-after($emails, $separator)"/>
                <xsl:with-param name="institutions" select="substring-after($institutions, $separator)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text()" name="split">
        <xsl:param name="separator" select="';'"/>
        <xsl:param name="string" select="''"/>
        <xsl:choose>
            <xsl:when test="contains($string, $separator)">
                <xsl:value-of select="substring-before($string, $separator)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Tokenize Metadataformats -->
    <!-- ======================== -->
    <xsl:template name="tokenizeMetadataLinksItems">
        <xsl:param name="datalist"/>
        <xsl:param name="oaiId"/>
        <xsl:choose>
            <xsl:when test="contains($datalist, $delimiter)">
                <xsl:variable name="processedItem">
                    <xsl:value-of select="substring-before($datalist, $delimiter)"/>
                </xsl:variable>
                <a class="btn btn-primary"
                   href="?verb=GetRecord&amp;metadataPrefix={$processedItem}&amp;identifier={$oaiId}"
                   title="Get record in {$processedItem} metadata format">
                    <i>
                        <xsl:attribute name="class">
                            <xsl:value-of select="$icon-formats"/>
                        </xsl:attribute>
                    </i>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="$processedItem"/>
                </a>
                <xsl:text>&#160;</xsl:text>
                <xsl:call-template name="tokenizeMetadataLinksItems">
                    <xsl:with-param name="datalist" select="substring-after($datalist, $delimiter)"/>
                    <xsl:with-param name="oaiId" select="$oaiId"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="string-length($datalist) = 1">
                <xsl:element name="processedItem">
                    <xsl:value-of select="$datalist"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- URL Encoder -->
    <!-- =========== -->
    <xsl:template name="url-encode">
        <xsl:param name="str"/>
        <xsl:if test="$str">
            <xsl:variable name="first-char" select="substring($str, 1, 1)"/>
            <xsl:choose>
                <xsl:when test="contains($safe, $first-char)">
                    <xsl:value-of select="$first-char"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="codepoint">
                        <xsl:choose>
                            <xsl:when test="contains($ascii, $first-char)">
                                <xsl:value-of select="string-length(substring-before($ascii, $first-char)) + 32"/>
                            </xsl:when>
                            <xsl:when test="contains($latin1, $first-char)">
                                <xsl:value-of select="string-length(substring-before($latin1, $first-char)) + 160"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message terminate="no">Warning: string contains a character that is out of range!
                                    Substituting "?".
                                </xsl:message>
                                <xsl:text>63</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="hex-digit1" select="substring($hex, floor($codepoint div 16) + 1, 1)"/>
                    <xsl:variable name="hex-digit2" select="substring($hex, $codepoint mod 16 + 1, 1)"/>
                    <xsl:value-of select="concat('%', $hex-digit1, $hex-digit2)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="string-length($str) &gt; 1">
                <xsl:call-template name="url-encode">
                    <xsl:with-param name="str" select="substring($str, 2)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!-- XML escape -->
    <!-- ========== -->
    <!-- See https://stackoverflow.com/questions/1162352/converting-xml-to-escaped-text-in-xslt -->
    <xsl:template match="oai:metadata/*" priority="-20">
        <xsl:apply-templates mode="escape" select="."/>
    </xsl:template>
    <xsl:template match="*" mode="escape">
        <!-- Begin opening tag -->
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <!-- Namespaces -->
        <xsl:for-each select="namespace::*">
            <xsl:text>&#160;xmlns</xsl:text>
            <xsl:if test="name() != ''">
                <xsl:text>:</xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:if>
            <xsl:text>='</xsl:text>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="."/>
            </xsl:call-template>
            <xsl:text>'</xsl:text>
        </xsl:for-each>
        <!-- Attributes -->
        <xsl:for-each select="@*">
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>='</xsl:text>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="."/>
            </xsl:call-template>
            <xsl:text>'</xsl:text>
        </xsl:for-each>
        <!-- End opening tag -->
        <xsl:text>&gt;</xsl:text>
        <!-- Content (child elements, text nodes, and PIs) -->
        <xsl:apply-templates mode="escape" select="node()"/>
        <!-- Closing tag -->
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="text()" mode="escape">
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="processing-instruction()" mode="escape">
        <xsl:text>&lt;?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
        <xsl:text>?&gt;</xsl:text>
    </xsl:template>
    <xsl:template name="escape-xml">
        <xsl:param name="text"/>
        <xsl:if test="$text != ''">
            <xsl:variable name="head" select="substring($text, 1, 1)"/>
            <xsl:variable name="tail" select="substring($text, 2)"/>
            <xsl:choose>
                <xsl:when test="$head = '&amp;'">&amp;amp;</xsl:when>
                <xsl:when test="$head = '&lt;'">&amp;lt;</xsl:when>
                <xsl:when test="$head = '&gt;'">&amp;gt;</xsl:when>
                <xsl:when test="$head = '&quot;'">&amp;quot;</xsl:when>
                <xsl:when test="$head = &quot;&apos;&quot;">&amp;apos;</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$head"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="$tail"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Error -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:error[1]">
        <h1 class="pb-2 border-bottom">Error in request</h1>
        <div class="container-fluid">
            <xsl:for-each select="../oai:error">
                <div class="alert alert-warning" role="alert">
                    <h4 class="alert-heading">
                        <xsl:value-of select="@code"/>
                    </h4>
                    <p>
                        <xsl:value-of select="text()"/>
                    </p>
                    <hr/>
                    <p class="mb-0">OAI-PMH Version 2.0 Specification:
                        <a href="https://www.openarchives.org/OAI/openarchivesprotocol.html" target="_blank">
                            https://www.openarchives.org/OAI/openarchivesprotocol.html
                        </a>
                    </p>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- GetRecords -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:GetRecord">
        <h1 class="pb-2 border-bottom text-break">Get Record:
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="/oai:OAI-PMH/oai:request/@identifier"/>
        </h1>
        <xsl:call-template name="responseInformation">
            <xsl:with-param name="pathEntities" select="/oai:OAI-PMH/oai:GetRecord/oai:record"/>
            <xsl:with-param name="pathResumptionToken" select="/oai:OAI-PMH/oai:GetRecord/oai:resumptionToken"/>
        </xsl:call-template>
        <div class="container-fluid g-4">
            <div aria-label="Information" class="btn-group mb-3" role="group">
                <button class="btn btn-primary" data-bs-target="#reponseInfoModal" data-bs-toggle="modal" type="button">
                    Response Information
                </button>
            </div>
            <xsl:for-each select="oai:record">
                <div class="card mb-3">
                    <div class="card-header">
                        <i>
                            <xsl:attribute name="class">
                                <xsl:value-of select="concat($icon-getrecord, ' ', 'h5')"/>
                            </xsl:attribute>
                        </i>
                        <xsl:text>&#160;Record</xsl:text>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <tbody>
                                    <tr>
                                        <th scope="row">Identifier</th>
                                        <td>
                                            <xsl:value-of select="oai:header/oai:identifier/text()"/>
                                        </td>
                                        <td class="text-end"/>
                                    </tr>
                                    <tr>
                                        <th scope="row">Metadata Prefix</th>
                                        <td>
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@metadataPrefix"/>
                                        </td>
                                        <td class="text-end">
                                            <div aria-label="Available Metadata formats" class="btn-group btn-group-sm"
                                                 role="group" style="white-space: nowrap;">
                                                <xsl:call-template name="tokenizeMetadataLinksItems">
                                                    <xsl:with-param name="datalist" select="$metadataFormats"/>
                                                    <xsl:with-param name="oaiId"
                                                                    select="oai:header/oai:identifier/text()"/>
                                                </xsl:call-template>
                                            </div>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="oai:header/oai:setSpec">
                                        <xsl:sort select="oai:header/oai:setSpec/text()"/>
                                        <tr>
                                            <th scope="row">Set</th>
                                            <td>
                                                <xsl:value-of select="text()"/>
                                            </td>
                                            <td class="text-end">
                                                <div aria-label="Available Metadata formats"
                                                     class="btn-group btn-group-sm" role="group"
                                                     style="white-space: nowrap;">
                                                    <xsl:variable name="urlencodedSetId">
                                                        <xsl:call-template name="url-encode">
                                                            <xsl:with-param name="str" select="text()"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    <a class="btn btn-primary"
                                                       href="?verb=ListIdentifiers&amp;metadataPrefix={/oai:OAI-PMH/oai:request/@metadataPrefix}&amp;set={$urlencodedSetId}"
                                                       title="List all identifiers in this set" type="button">
                                                        <i>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="$icon-identifiers"/>
                                                            </xsl:attribute>
                                                        </i>
                                                        <xsl:text>&#160;List Identifiers</xsl:text>
                                                    </a>
                                                    <a class="btn btn-primary"
                                                       href="?verb=ListRecords&amp;metadataPrefix={/oai:OAI-PMH/oai:request/@metadataPrefix}&amp;set={$urlencodedSetId}"
                                                       title="List all records in this set" type="button">
                                                        <i>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="$icon-records"/>
                                                            </xsl:attribute>
                                                        </i>
                                                        <xsl:text>&#160;List Records</xsl:text>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                        <xsl:choose>
                            <xsl:when test="oai:header/@status = 'deleted'">
                                <h3>Deleted Record</h3>
                            </xsl:when>
                            <xsl:when test="not(oai:about)">
                                <pre>
                                    <code class="language-xml">
                                        <xsl:apply-templates select="oai:metadata/*"/>
                                    </code>
                                </pre>
                            </xsl:when>
                            <xsl:otherwise>
                                <h3>Metadata</h3>
                                <xsl:apply-templates select="oai:metadata/*"/>
                                <h3>About</h3>
                                <xsl:apply-templates mode="escape" select="oai:about/*"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Identify -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:Identify">
        <h1 class="pb-2 border-bottom">Repository Information</h1>
        <div class="table-responsive g-4">
            <table class="table">
                <tbody>
                    <xsl:if test="oai:repositoryName">
                        <tr>
                            <th scope="row" style="width:25%">Repository Name</th>
                            <td>
                                <xsl:value-of select="oai:repositoryName/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:baseURL">
                        <tr>
                            <th scope="row" style="width:25%">Repository Base Url</th>
                            <td>
                                <a href="{oai:baseURL/text()}">
                                    <xsl:value-of select="oai:baseURL/text()"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:adminEmail"/>
                    <tr>
                        <th scope="row" style="width:25%">E-Mail Contact</th>
                        <td>
                            <xsl:for-each select="oai:adminEmail">
                                <a href="{concat('mailto:', text())}">
                                    <xsl:value-of select="text()"/>
                                </a>
                                <xsl:if test="position() != last()">
                                    <xsl:text>,&#160;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </td>
                    </tr>
                    <xsl:if test="oai:protocolVersion">
                        <tr>
                            <th scope="row" style="width:25%">Protocol Version</th>
                            <td>
                                <xsl:value-of select="oai:protocolVersion/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:earliestDatestamp">
                        <tr>
                            <th scope="row" style="width:25%">Earliest Registered Date</th>
                            <td>
                                <xsl:value-of select="translate(oai:earliestDatestamp/text(), 'TZ', ' ')"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:granularity">
                        <tr>
                            <th scope="row" style="width:25%">Date Granularity</th>
                            <td>
                                <xsl:value-of select="translate(oai:granularity/text(), 'TZ', ' ')"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:deletedRecord">
                        <tr>
                            <th scope="row" style="width:25%">Deletion Mode</th>
                            <td>
                                <xsl:value-of select="oai:deletedRecord/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai:compression">
                        <tr>
                            <th scope="row" style="width:25%">Compression</th>
                            <td>
                                <xsl:value-of select="oai:compression/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                </tbody>
            </table>
        </div>
        <xsl:apply-templates select="oai:description"/>
    </xsl:template>
    <!-- Identify: Description -->
    <!-- ===================== -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description">
        <xsl:apply-templates select="oai_identifier:oai-identifier"/>
        <xsl:apply-templates select="oai_rights:rightsManifest"/>
        <xsl:apply-templates select="oai_friends:friends"/>
        <xsl:apply-templates select="oai_branding:branding"/>
        <xsl:apply-templates select="oai_gateway:gateway"/>
        <xsl:apply-templates
                select="./*[local-name() != 'oai-identifier' and local-name() != 'rightsManifest' and local-name() != 'gateway' and local-name() != 'friends' and local-name() != 'branding']"/>
    </xsl:template>
    <!-- Identify: Description -->
    <!-- ===================== -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/*" priority="-100">
        <h2 class="mt-3">Other Description Type</h2>
        <pre>
            <code class="language-xml">
                <xsl:apply-templates mode="escape" select="."/>
            </code>
        </pre>
    </xsl:template>
    <!-- Identify: Identifier -->
    <!-- ==================== -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/oai_identifier:oai-identifier">
        <h2 class="mt-3">Identifiers Format</h2>
        <div class="table-responsive g-4">
            <table class="table">
                <tbody>
                    <xsl:if test="oai_identifier:scheme">
                        <tr>
                            <th scope="row" style="width:25%">Scheme</th>
                            <td>
                                <xsl:value-of select="oai_identifier:scheme/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_identifier:repositoryIdentifier">
                        <tr>
                            <th scope="row" style="width:25%">Repository identifier</th>
                            <td>
                                <xsl:value-of select="oai_identifier:repositoryIdentifier/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_identifier:delimiter">
                        <tr>
                            <th scope="row" style="width:25%">Delimiter</th>
                            <td>
                                <code>
                                    <xsl:value-of select="oai_identifier:delimiter/text()"/>
                                </code>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_identifier:sampleIdentifier">
                        <tr>
                            <th scope="row" style="width:25%">Sample identifier</th>
                            <td>
                                <xsl:value-of select="oai_identifier:sampleIdentifier/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <!-- Identify: Description -->
    <!-- ===================== -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/oai_rights:rightsManifest">
        <h2 class="mt-3">Rights Manifest</h2>
        <pre>
            <code class="language-xml">
                <xsl:apply-templates mode="escape" select="."/>
            </code>
        </pre>
    </xsl:template>
    <!-- Identify: Rights Manifest -->
    <!-- ========================= -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/oai_friends:friends">
        <h2 class="mt-3">Confederated Repositories</h2>
        <xsl:choose>
            <xsl:when test="count(oai_friends:baseURL) > 0">
                <div class="table-responsive g-4">
                    <table class="table">
                        <tbody>
                            <xsl:for-each select="oai_friends:baseURL">
                                <tr>
                                    <th scope="row" style="width:25%">
                                        <xsl:value-of select="position()"/>
                                    </th>
                                    <td>
                                        <a href="{concat(text(), '?verb=Identify')}">
                                            <xsl:value-of select="text()"/>
                                        </a>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <p>None</p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Identify: Branding -->
    <!-- ================== -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/oai_branding:branding">
        <h2 class="mt-3">Branding</h2>
        <pre>
            <code class="language-xml">
                <xsl:apply-templates mode="escape" select="."/>
            </code>
        </pre>
    </xsl:template>
    <!-- Identify: Gateway -->
    <!-- ================= -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/oai_gateway:gateway">
        <h2 class="mt-3">OAI-PMH Gateway</h2>
        <div class="table-responsive g-4">
            <table class="table">
                <tbody>
                    <xsl:if test="oai_gateway:gatewayURL">
                        <tr>
                            <th scope="row" style="width:25%">OAI-PMH Gateway</th>
                            <td>
                                <a href="{oai_gateway:gatewayURL/text()}">
                                    <xsl:value-of select="oai_gateway:gatewayURL/text()"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_gateway:source">
                        <tr>
                            <th scope="row" style="width:25%">Source</th>
                            <td>
                                <xsl:value-of select="oai_gateway:source/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_gateway:gatewayAdmin">
                        <tr>
                            <th scope="row" style="width:25%">E-Mail Contact</th>
                            <td>
                                <a href="{concat('mailto:', oai_gateway:gatewayAdmin/text())}">
                                    <xsl:value-of select="oai_gateway:gatewayAdmin/text()"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="oai_gateway:gatewayNotes">
                        <tr>
                            <th scope="row" style="width:25%">Policy</th>
                            <td>
                                <a href="{oai_gateway:gatewayNotes/text()}">
                                    <xsl:value-of select="oai_gateway:gatewayNotes/text()"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <!-- Identify: Toolkit -->
    <!-- ================= -->
    <xsl:template match="oai:OAI-PMH/oai:Identify/oai:description/toolkit:toolkit">
        <h2 class="mt-3">Toolkit</h2>
        <div class="table-responsive g-4">
            <table class="table">
                <tbody>
                    <xsl:if test="toolkit:title">
                        <tr>
                            <th scope="row">Title</th>
                            <td>
                                <xsl:value-of select="toolkit:title/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="toolkit:author">
                        <tr>
                            <th scope="row">Author</th>
                            <td>
                                <xsl:call-template name="authors-split">
                                    <xsl:with-param name="authors" select="toolkit:author/toolkit:name/text()"/>
                                    <xsl:with-param name="emails" select="toolkit:author/toolkit:email/text()"/>
                                    <xsl:with-param name="institutions"
                                                    select="toolkit:author/toolkit:institution/text()"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="toolkit:version">
                        <tr>
                            <th scope="row">Version</th>
                            <td>
                                <xsl:value-of select="toolkit:version/text()"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="toolkit:toolkitIcon">
                        <tr>
                            <th scope="row">Toolkit icon</th>
                            <td>
                                <xsl:if test="toolkit:toolkitIcon/text() != ''">
                                    <a href="{toolkit:toolkitIcon/text()}">
                                        <xsl:value-of select="toolkit:toolkitIcon/text()"/>
                                    </a>
                                    <img class="oaipmh-toolkit-icon" src="{toolkit:toolkitIcon/text()}"/>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="toolkit:URL">
                        <tr>
                            <th scope="row">Url</th>
                            <td>
                                <a href="{toolkit:URL/text()}">
                                    <xsl:value-of select="toolkit:URL/text()"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- ListIdentifiers -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:ListIdentifiers">
        <xsl:variable name="first-result">
            <xsl:call-template name="first-result">
                <xsl:with-param name="path" select="oai:header"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="metadata-prefix">
            <xsl:call-template name="metadata-prefix"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="/oai:OAI-PMH/oai:request/@set">
                <h1 class="pb-2 border-bottom text-break">List Identifiers:
                    <xsl:value-of select="/oai:OAI-PMH/oai:request/@set"/>
                    <xsl:text> </xsl:text>
                    <span class="badge bg-secondary">
                        <xsl:value-of select="count(oai:header)"/>
                        <xsl:if test="oai:resumptionToken/text() != ''">
                            <xsl:text>+</xsl:text>
                        </xsl:if>
                    </span>
                </h1>
            </xsl:when>
            <xsl:otherwise>
                <h1 class="pb-2 border-bottom text-break">List Identifiers
                    <xsl:text>&#160;</xsl:text>
                    <span class="badge bg-secondary">
                        <xsl:value-of select="count(oai:header)"/>
                        <xsl:if test="oai:resumptionToken/text() != ''">
                            <xsl:text>+</xsl:text>
                        </xsl:if>
                    </span>
                </h1>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="responseInformation">
            <xsl:with-param name="pathEntities" select="/oai:OAI-PMH/oai:ListIdentifiers/oai:header"/>
            <xsl:with-param name="pathResumptionToken" select="/oai:OAI-PMH/oai:ListIdentifiers/oai:resumptionToken"/>
        </xsl:call-template>
        <xsl:call-template name="timespanModal"/>
        <!-- Spinner -->
        <div class="text-center" id="loading">
            <div class="d-flex justify-content-center">
                <div class="spinner-border" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
            </div>
        </div>
        <div class="table-responsive g-4">
            <!-- Back to top button -->
            <button class="btn btn-primary btn-floating" id="btn-back-to-top" type="button">
                <i class="bi bi-arrow-up-short"/>
            </button>
            <table class="table" id="datatable" style="display: none;">
                <thead>
                    <tr>
                        <th data-priority="10">No.</th>
                        <th data-priority="0">
                            <xsl:text>Identifier</xsl:text>
                        </th>
                        <th data-priority="1">
                            <xsl:text>Last modified</xsl:text>
                        </th>
                        <th data-priority="2">
                            <xsl:text>Actions</xsl:text>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="oai:header">
                        <tr>
                            <th scope="row">
                                <xsl:if test="@status = 'deleted'">
                                    <xsl:attribute name="class">
                                        <xsl:text>text-muted</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="position() + $first-result"/>
                            </th>
                            <td>
                                <xsl:if test="@status = 'deleted'">
                                    <xsl:attribute name="class">
                                        <xsl:text>text-muted</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="oai:identifier/text()"/>
                            </td>
                            <td>
                                <xsl:if test="@status = 'deleted'">
                                    <xsl:attribute name="class">
                                        <xsl:text>text-muted</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="translate(oai:datestamp/text(), 'TZ', ' ')"/>
                            </td>
                            <td>
                                <div aria-label="List of identifiers and records" class="btn-group btn-group-sm"
                                     role="group" style="white-space: nowrap;">
                                    <xsl:choose>
                                        <xsl:when test="@status = 'deleted'">
                                            <a class="btn btn-primary disabled" href="#">
                                                <xsl:text>Deleted Record</xsl:text>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a class="btn btn-primary">
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="/oai:OAI-PMH/oai:request/text()"/>
                                                    <xsl:text>?verb=GetRecord&amp;metadataPrefix=</xsl:text>
                                                    <xsl:value-of select="$metadata-prefix"/>
                                                    <xsl:text>&amp;identifier=</xsl:text>
                                                    <xsl:value-of select="oai:identifier/text()"/>
                                                </xsl:attribute>
                                                <xsl:text>View Record</xsl:text>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:call-template name="display-button-sets">
                                        <xsl:with-param name="path" select="oai:setSpec"/>
                                    </xsl:call-template>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
        <xsl:apply-templates select="oai:resumptionToken"/>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- ListMetadataFormats -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:ListMetadataFormats">
        <h1 class="pb-2 border-bottom">List Metadata Formats
            <xsl:text>&#160;</xsl:text>
            <span class="badge bg-secondary">
                <xsl:value-of select="count(oai:metadataFormat)"/>
            </span>
        </h1>
        <div class="row g-4 py-5 row-cols-1 row-cols-sm-1 row-cols-md-1 row-cols-lg-2 row-cols-xl-3 row-cols-xxl-4">
            <xsl:for-each select="oai:metadataFormat">
                <xsl:sort select="oai:metadataPrefix/text()"/>
                <div class="col d-flex align-items-start mb-3">
                    <div class="flex-shrink-0 me-3 text-secondary">
                        <i>
                            <xsl:attribute name="class">
                                <xsl:value-of select="concat($icon-formats, ' ', 'h2')"/>
                            </xsl:attribute>
                        </i>
                    </div>
                    <div>
                        <h2>
                            <xsl:value-of select="oai:metadataPrefix/text()"/>
                        </h2>
                        <dl>
                            <dt>Namespace</dt>
                            <dd class="text-break">
                                <a href="{oai:metadataNamespace/text()}" target="_blank">
                                    <xsl:value-of select="oai:metadataNamespace/text()"/>
                                </a>
                            </dd>
                            <dt>Schema</dt>
                            <dd class="text-break">
                                <a href="{oai:schema/text()}" target="_blank">
                                    <xsl:value-of select="oai:schema/text()"/>
                                </a>
                            </dd>
                        </dl>
                        <div aria-label="List" class="btn-group btn-group-sm" role="group">
                            <a class="btn btn-primary"
                               href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=ListIdentifiers&amp;metadataPrefix=', oai:metadataPrefix/text())}"
                               type="button">
                                <i>
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="$icon-identifiers"/>
                                    </xsl:attribute>
                                </i>
                                <xsl:text>&#160;List Identifiers</xsl:text>
                            </a>
                            <a class="btn btn-primary"
                               href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=ListRecords&amp;metadataPrefix=', oai:metadataPrefix/text())}"
                               type="button">
                                <i>
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="$icon-records"/>
                                    </xsl:attribute>
                                </i>
                                <xsl:text>&#160;List Records</xsl:text>
                            </a>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- ListRecords -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:ListRecords">
        <xsl:choose>
            <xsl:when test="/oai:OAI-PMH/oai:request/@set">
                <h1 class="pb-2 border-bottom text-break">List Records:
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="/oai:OAI-PMH/oai:request/@set"/>
                    <xsl:text> </xsl:text>
                    <span class="badge bg-secondary">
                        <xsl:value-of select="count(oai:record)"/>
                        <xsl:if test="oai:resumptionToken/@completeListSize">
                            <xsl:text>+</xsl:text>
                        </xsl:if>
                    </span>
                </h1>
            </xsl:when>
            <xsl:otherwise>
                <h1 class="pb-2 border-bottom">List Records
                    <xsl:text>&#160;</xsl:text>
                    <span class="badge bg-secondary">
                        <xsl:value-of select="count(oai:record)"/>
                        <xsl:if test="oai:resumptionToken/@completeListSize">
                            <xsl:text>+</xsl:text>
                        </xsl:if>
                    </span>
                </h1>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="responseInformation">
            <xsl:with-param name="pathEntities" select="/oai:OAI-PMH/oai:ListRecords/oai:record"/>
            <xsl:with-param name="pathResumptionToken" select="/oai:OAI-PMH/oai:ListRecords/oai:resumptionToken"/>
        </xsl:call-template>
        <xsl:call-template name="timespanModal"/>
        <div class="container-fluid g-4">
            <div aria-label="Information" class="btn-group mb-3" role="group">
                <button class="btn btn-primary" data-bs-target="#reponseInfoModal" data-bs-toggle="modal" type="button">
                    Response Information
                </button>
                <button class="btn btn-primary" data-bs-target="#timespanModal" data-bs-toggle="modal" type="button">
                    Timespan
                </button>
            </div>
            <xsl:for-each select="oai:record">
                <div class="card mb-3">
                    <xsl:choose>
                        <xsl:when test="oai:header/@status = 'deleted'">
                            <xsl:attribute name="class">
                                <xsl:text>card mb-3 text-muted</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">
                                <xsl:text>card mb-3</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <div class="card-header">
                        <i>
                            <xsl:attribute name="class">
                                <xsl:value-of select="concat($icon-getrecord, ' ', 'h5')"/>
                            </xsl:attribute>
                        </i>
                        <xsl:text>&#160;Record&#160;</xsl:text>
                        <xsl:value-of select="position()"/>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <tbody>
                                    <tr>
                                        <th scope="row">Identifier</th>
                                        <td>
                                            <xsl:value-of select="oai:header/oai:identifier/text()"/>
                                        </td>
                                        <td class="text-end"/>
                                    </tr>
                                    <tr>
                                        <th scope="row">Metadata Prefix</th>
                                        <td>
                                            <xsl:value-of select="/oai:OAI-PMH/oai:request/@metadataPrefix"/>
                                        </td>
                                        <td class="text-end">
                                            <div aria-label="Available Metadata formats" class="btn-group btn-group-sm"
                                                 role="group" style="white-space: nowrap;">
                                                <xsl:call-template name="tokenizeMetadataLinksItems">
                                                    <xsl:with-param name="datalist" select="$metadataFormats"/>
                                                    <xsl:with-param name="oaiId"
                                                                    select="oai:header/oai:identifier/text()"/>
                                                </xsl:call-template>
                                            </div>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="oai:header/oai:setSpec">
                                        <xsl:sort select="oai:header/oai:setSpec/text()"/>
                                        <xsl:variable name="urlencodedSetId">
                                            <xsl:call-template name="url-encode">
                                                <xsl:with-param name="str" select="text()"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <tr>
                                            <th scope="row">Set</th>
                                            <td>
                                                <xsl:value-of select="text()"/>
                                            </td>
                                            <td class="text-end">
                                                <div aria-label="Available Metadata formats"
                                                     class="btn-group btn-group-sm" role="group"
                                                     style="white-space: nowrap;">
                                                    <a class="btn btn-primary"
                                                       href="?verb=ListIdentifiers&amp;metadataPrefix={/oai:OAI-PMH/oai:request/@metadataPrefix}&amp;set={$urlencodedSetId}"
                                                       title="List all identifiers in this set" type="button">
                                                        <i>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="$icon-identifiers"/>
                                                            </xsl:attribute>
                                                        </i>
                                                        <xsl:text>&#160;List Identifiers</xsl:text>
                                                    </a>
                                                    <a class="btn btn-primary"
                                                       href="?verb=ListRecords&amp;metadataPrefix={/oai:OAI-PMH/oai:request/@metadataPrefix}&amp;set={$urlencodedSetId}"
                                                       title="List all records in this set" type="button">
                                                        <i>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="$icon-records"/>
                                                            </xsl:attribute>
                                                        </i>
                                                        <xsl:text>&#160;List Records</xsl:text>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                    <xsl:if test="oai:header/@status = 'deleted'">
                                        <tr>
                                            <th scope="row">Status</th>
                                            <td>Deleted</td>
                                        </tr>
                                    </xsl:if>
                                </tbody>
                            </table>
                        </div>
                        <xsl:if test="not(oai:header/@status) or oai:header/@status != 'deleted'">
                            <p>
                                <b>Metadata</b>
                            </p>
                            <pre>
                                <code class="language-xml">
                                    <xsl:apply-templates mode="escape" select="oai:metadata/*"/>
                                </code>
                            </pre>
                            <xsl:if test="oai:about">
                                <p>
                                    <b>About</b>
                                </p>
                                <pre>
                                    <code class="language-xml">
                                        <xsl:apply-templates mode="escape" select="oai:about/*"/>
                                    </code>
                                </pre>
                            </xsl:if>
                        </xsl:if>
                    </div>
                </div>
            </xsl:for-each>
        </div>
        <xsl:apply-templates select="oai:resumptionToken"/>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- ListSets -->
    <!-- ============================================================================================= -->
    <xsl:template match="oai:OAI-PMH/oai:ListSets">
        <xsl:variable name="first-result">
            <xsl:call-template name="first-result">
                <xsl:with-param name="path" select="oai:set"/>
            </xsl:call-template>
        </xsl:variable>
        <h1 class="pb-2 border-bottom">List Sets
            <xsl:text>&#160;</xsl:text>
            <span class="badge bg-secondary">
                <xsl:value-of select="count(oai:set)"/>
                <xsl:if test="oai:resumptionToken/@completeListSize">
                    <xsl:text>+</xsl:text>
                </xsl:if>
            </span>
        </h1>
        <xsl:call-template name="responseInformation">
            <xsl:with-param name="pathEntities" select="/oai:OAI-PMH/oai:ListSets/oai:set"/>
            <xsl:with-param name="pathResumptionToken" select="/oai:OAI-PMH/oai:ListSets/oai:resumptionToken"/>
        </xsl:call-template>
        <!-- Spinner -->
        <div class="text-center" id="loading">
            <div class="d-flex justify-content-center">
                <div class="spinner-border" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
            </div>
        </div>
        <div class="table-responsive g-4 py-5">
            <!-- Back to top button -->
            <button class="btn btn-primary btn-floating" id="btn-back-to-top" type="button">
                <i class="bi bi-arrow-up-short"/>
            </button>
            <table class="table table-bordered table-striped" id="datatable" style="display: none;">
                <thead>
                    <tr>
                        <th data-priority="10">No.</th>
                        <th data-priority="0">
                            <xsl:text>Set Spec</xsl:text>
                        </th>
                        <th data-priority="1">
                            <xsl:text>Set Name</xsl:text>
                        </th>
                        <th data-priority="2">
                            <xsl:text>Actions</xsl:text>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="oai:set">
                        <xsl:sort select="oai:setSpec/text()"/>
                        <tr>
                            <td scope="row">
                                <xsl:value-of select="position() + $first-result"/>
                            </td>
                            <td>
                                <span data-bs-html="true" data-bs-toggle="tooltip" title="Tooltip with Text">
                                    <xsl:value-of select="oai:setSpec/text()"/>
                                </span>
                            </td>
                            <td>
                                <xsl:value-of select="oai:setName/text()"/>
                            </td>
                            <!--<td>
                                    <xsl:value-of select="oai:setDescription/*[namespace-uri() = 'http://www.openarchives.org/OAI/2.0/oai_dc/' and local-name() = 'dc']/*[namespace-uri() = 'http://purl.org/dc/elements/1.1/' and local-name() = 'description']" />
                                </td>-->
                            <td>
                                <div aria-label="List of identifiers and records" class="btn-group btn-group-sm"
                                     role="group" style="white-space: nowrap;">
                                    <xsl:choose>
                                        <xsl:when test="oai:setDescription != ''">
                                            <a class="btn btn-primary" data-toggle="collapse"
                                               href="{concat('#', translate(oai:setSpec/text(), $forbidden-characters, ''))}">
                                                <i>
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="$icon-description"/>
                                                    </xsl:attribute>
                                                </i>
                                                <xsl:text>&#160;Description&#160;</xsl:text>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a class="btn btn-primary disabled" href="#">
                                                <i>
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="$icon-description"/>
                                                    </xsl:attribute>
                                                </i>
                                                <xsl:text>&#160;Description</xsl:text>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <a class="btn btn-primary"
                                       href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=ListIdentifiers&amp;metadataPrefix=oai_dc&amp;set=', oai:setSpec/text())}">
                                        <i>
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="$icon-identifiers"/>
                                            </xsl:attribute>
                                        </i>
                                        <xsl:text>&#160;List Identifiers</xsl:text>
                                    </a>
                                    <a class="btn btn-primary"
                                       href="{concat(/oai:OAI-PMH/oai:request/text(), '?verb=ListRecords&amp;metadataPrefix=oai_dc&amp;set=', oai:setSpec/text())}">
                                        <i>
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="$icon-records"/>
                                            </xsl:attribute>
                                        </i>
                                        <xsl:text>&#160;List Records</xsl:text>
                                    </a>
                                </div>
                                <xsl:if test="oai:setDescription != ''">
                                    <div class="collapse"
                                         id="{translate(oai:setSpec/text(), $forbidden-characters, '')}">
                                        <hr/>
                                        <xsl:apply-templates mode="escape" select="oai:setDescription/*"/>
                                    </div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
        <xsl:apply-templates select="oai:resumptionToken"/>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Root -->
    <!-- ==== -->
    <xsl:template match="/">
        <html lang="en">
            <head>
                <xsl:element name="meta">
                    <xsl:attribute name="http-equiv">X-UA-Compatible</xsl:attribute>
                    <xsl:attribute name="content">IE=edge</xsl:attribute>
                </xsl:element>
                <xsl:element name="meta">
                    <xsl:attribute name="name">viewport</xsl:attribute>
                    <xsl:attribute name="content">width=device-width, initial-scale=1.0</xsl:attribute>
                </xsl:element>
                <xsl:element name="meta">
                    <xsl:attribute name="name">description</xsl:attribute>
                    <xsl:attribute name="content">OAI-PMH Repository and OAI-PMH Data Provider</xsl:attribute>
                </xsl:element>
                <link rel="icon">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$favicon"/>
                    </xsl:attribute>
                </link>
                <title>
                    <xsl:value-of select="$homepage-text"/>
                </title>
                <link crossorigin="anonymous"
                      href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/css/bootstrap.min.css"
                      integrity="sha512-XWTTruHZEYJsxV3W/lSXG1n3Q39YIWOstqvmFsdNEEQfHoZ6vm6E9GK2OrF6DSJSpIbRbi+Nn0WDPID9O7xB2Q=="
                      referrerpolicy="no-referrer" rel="stylesheet"/>
                <link href="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/date-1.1.2/fh-3.2.4/r-2.3.0/sc-2.0.7/datatables.min.css"
                      rel="stylesheet" type="text/css"/>
                <link crossorigin="anonymous"
                      href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.9.1/font/bootstrap-icons.min.css"
                      integrity="sha512-5PV92qsds/16vyYIJo3T/As4m2d8b6oWYfoqV+vtizRB6KhF1F9kYzWzQmsO6T3z3QG2Xdhrx7FQ+5R1LiQdUA=="
                      referrerpolicy="no-referrer" rel="stylesheet"/>
                <link crossorigin="anonymous"
                      href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/default.min.css"
                      integrity="sha512-hasIneQUHlh06VNBe7f6ZcHmeRTLIaQWFd43YriJ0UND19bvYRauxthDg8E4eVNPm9bRUhr5JGeqH7FRFXQu5g=="
                      referrerpolicy="no-referrer" rel="stylesheet"/>
                <!-- <link crossorigin="anonymous" href="https://cdnjs.cloudflare.com/ajax/libs/bootswatch/5.2.0/flatly/bootstrap.min.css" integrity="sha512-SAOc0O+NBGM2HuPF20h4nse270bwZJi8X90t5k/ApuB9oasBYEyLJ7WtYcWZARWiSlKJpZch1+ip2mmhvlIvzQ==" referrerpolicy="no-referrer" rel="stylesheet" /> -->
                <!-- <link crossorigin="anonymous" href="https://cdnjs.cloudflare.com/ajax/libs/bootswatch/5.2.0/united/bootstrap.min.css" integrity="sha512-AX1kMwMsjj6hzp48ryOSralgDrfE/6XbweeqN923ABTRXoYcuJy54ljy9I7R/FLIfuBxRjRf/shWi5ogzwgzaA==" referrerpolicy="no-referrer" rel="stylesheet" /> -->
                <!-- <link crossorigin="anonymous" href="https://cdnjs.cloudflare.com/ajax/libs/bootswatch/5.2.0/simplex/bootstrap.min.css" integrity="sha512-IvyqbW9yjRXS1Xm4KQo/7LfTDG0j3QZUWYEV5eWJp1VP9XA3dzucZSWbuUjd2/E2svDVAPztyyKKGz5qt2Cv9Q==" referrerpolicy="no-referrer" rel="stylesheet" /> -->
                <!-- <link crossorigin="anonymous" href="https://cdnjs.cloudflare.com/ajax/libs/bootswatch/5.2.0/slate/bootstrap.min.css" integrity="sha512-R4B28W0n4tNv17cFGnLJJEjHkpbpKWi2XE+OyqSAkJa43DsAPVxpnjInGES8QGE6AL8kwtjeQ56hY/kYdUkMCQ==" referrerpolicy="no-referrer" rel="stylesheet" /> -->
                <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootswatch/5.2.0/lux/bootstrap.min.css" integrity="sha512-X2LR7g52cSDb7+Sdq0+wdpKfpYkLW1Q+Q21VrF1g9F7ubW6DE7Yncm7qd20F8NU/XMt2+uUhnD5WcLZenCDCxg==" crossorigin="anonymous" referrerpolicy="no-referrer" /> -->
                <!-- etc. -->
                <style>
                    #btn-back-to-top {
                    position: fixed;
                    bottom: 18px;
                    left: 12px;
                    display: none;
                    z-index: 10000;
                    }
                </style>
            </head>
            <body>
                <nav class="navbar navbar-expand-lg bg-light mb-5">
                    <div class="container-fluid">
                        <a class="navbar-brand">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat(/oai:OAI-PMH/oai:request/text(), '?verb=Identify')"/>
                            </xsl:attribute>
                            <xsl:if test="$homepage-logo != ''">
                                <img alt="Logo von DDBpro" class="d-inline-block align-text-top" height="65">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$homepage-logo"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:if>
                            <xsl:if test="$homepage-logo-text != ''">
                                <span class="fs-4">
                                    <xsl:value-of select="$homepage-logo-text"/>
                                </span>
                            </xsl:if>
                        </a>
                        <button aria-controls="navbarNavAltMarkup" aria-expanded="false" aria-label="Toggle navigation"
                                class="navbar-toggler" data-bs-target="#navbarNavAltMarkup" data-bs-toggle="collapse"
                                type="button">
                            <span class="navbar-toggler-icon"/>
                        </button>
                        <div class="collapse navbar-collapse flex-grow-1 text-right mt-3" id="navbarNavAltMarkup">
                            <div class="navbar-nav ms-auto flex-nowrap">
                                <ul class="navbar-nav ml-auto">
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'Identify'"/>
                                        <xsl:with-param name="title" select="'Identify: Institutional information'"/>
                                        <xsl:with-param name="icon" select="$icon-identify"/>
                                        <xsl:with-param name="verb" select="'Identify'"/>
                                        <xsl:with-param name="metadataPrefix" select="''"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'List Metadata Formats'"/>
                                        <xsl:with-param name="title"
                                                        select="'ListMetadataFormats: Metadata Formats available'"/>
                                        <xsl:with-param name="icon" select="$icon-formats"/>
                                        <xsl:with-param name="verb" select="'ListMetadataFormats'"/>
                                        <xsl:with-param name="metadataPrefix" select="''"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'List Sets'"/>
                                        <xsl:with-param name="title" select="'ListSets: Listing available sets'"/>
                                        <xsl:with-param name="icon" select="$icon-sets"/>
                                        <xsl:with-param name="verb" select="'ListSets'"/>
                                        <xsl:with-param name="metadataPrefix" select="''"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'List Identifiers'"/>
                                        <xsl:with-param name="title"
                                                        select="'ListIdentifiers: Listing identifiers only'"/>
                                        <xsl:with-param name="icon" select="$icon-identifiers"/>
                                        <xsl:with-param name="verb" select="'ListIdentifiers'"/>
                                        <xsl:with-param name="metadataPrefix" select="'oai_dc'"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'List Records'"/>
                                        <xsl:with-param name="title"
                                                        select="'ListRecords: Listing records with metadata'"/>
                                        <xsl:with-param name="icon" select="$icon-records"/>
                                        <xsl:with-param name="verb" select="'ListRecords'"/>
                                        <xsl:with-param name="metadataPrefix" select="'oai_dc'"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="nav-link">
                                        <xsl:with-param name="text" select="'Get Record'"/>
                                        <xsl:with-param name="title" select="'GetRecord: Get one Record'"/>
                                        <xsl:with-param name="icon" select="$icon-getrecord"/>
                                        <xsl:with-param name="verb" select="'GetRecord'"/>
                                        <xsl:with-param name="metadataPrefix" select="'oai_dc'"/>
                                    </xsl:call-template>
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>
                <div class="container-fluid">
                    <div class="row">
                        <xsl:apply-templates select="oai:OAI-PMH/oai:error"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:Identify"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:ListMetadataFormats"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:ListSets"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:ListIdentifiers"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords"/>
                        <xsl:apply-templates select="oai:OAI-PMH/oai:GetRecord"/>
                    </div>
                </div>
                <!-- JavaScript Bundle -->
                <script crossorigin="anonymous"
                        integrity="sha512-qzrZqY/kMVCEYeu/gCm8U2800Wz++LTGK4pitW/iswpCbjwxhsmUwleL1YXaHImptCHG0vJwU7Ly7ROw3ZQoww=="
                        referrerpolicy="no-referrer"
                        src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"/>
                <script crossorigin="anonymous"
                        integrity="sha512-8cU710tp3iH9RniUh6fq5zJsGnjLzOWLWdZqBMLtqaoZUA6AWIE34lwMB3ipUNiTBP5jEZKY95SfbNnQ8cCKvA=="
                        referrerpolicy="no-referrer"
                        src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.11.5/umd/popper.min.js"/>
                <script crossorigin="anonymous"
                        integrity="sha512-9GacT4119eY3AcosfWtHMsT5JyZudrexyEVzTBWV3viP/YfB9e2pEy3N7WXL3SV6ASXpTU0vzzSxsbfsuUH4sQ=="
                        referrerpolicy="no-referrer"
                        src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/js/bootstrap.bundle.min.js"/>
                <!-- Highlight Source code -->
                <xsl:if test="oai:OAI-PMH/oai:GetRecord or oai:OAI-PMH/oai:ListRecords or oai:OAI-PMH/oai:Identify">
                    <script crossorigin="anonymous"
                            integrity="sha512-gU7kztaQEl7SHJyraPfZLQCNnrKdaQi5ndOyt4L4UPL/FHDd/uB9Je6KDARIqwnNNE27hnqoWLBq+Kpe4iHfeQ=="
                            referrerpolicy="no-referrer"
                            src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"/>
                    <script>
                        <![CDATA[
                        $(document).ready(function () {
                            hljs.highlightAll();   
                        });
                        ]]>
                    </script>
                </xsl:if>
                <xsl:if test="oai:OAI-PMH/oai:ListSets or oai:OAI-PMH/oai:ListIdentifiers">
                    <script src="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/date-1.1.2/fh-3.2.4/r-2.3.0/sc-2.0.7/datatables.min.js"/>
                    <script>
                        <![CDATA[
                        $(document).ready(function() {
                           var table = $('#datatable').DataTable({
                               "dom": 'Bifrtp',
                               "responsive": true,
                               "paging": true,
                               "pagingType": "first_last_numbers",
                               "pageLength": 1000,
                               "lengthMenu": [
                                   [10, 100, 1000, 10000, 100000, 1000000, -1],
                                   [10, 100, 1000, 10000, 100000, 1000000, "All"]
                               ],
                               "language": {
                                   "processing": '<div class="spinner-border text-secondary" role="status" style="width: 3rem; height: 3rem; z-index: 20;"></div>'
                               },
                               "processing": true,
                               "buttons": [{
                                       text: 'Response Information',
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       },
                                       attr: {
                                           id: 'respInfoBtn'
                                       },
                                       action: function(e, dt, button, config) {
                                           $('#reponseInfoModal').modal('toggle');
                                       },
                                   },
                                   {
                                       extend: "pageLength",
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       }
                                   },
                                   {
                                       extend: "colvis",
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       }
                                   },
                                   {
                                       extend: "copy",
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       }
                                   },
                                   {
                                       extend: "excel",
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       }
                                   },
                                   {
                                       extend: "print",
                                       className: "btn-primary",
                                       init: function(api, node, config) {
                                           $(node).removeClass('btn-secondary');
                                       }
                                   }
                               ],
                               "initComplete": function() {
                                   $("#datatable").show();
                                   $("#loading").remove();
                               }
                           });
                           new $.fn.dataTable.FixedHeader(table);
                           $(function() {
                               $(window).scroll(function() {
                                   if ($(this).scrollTop() > 100) {
                                       $('#btn-back-to-top').fadeIn();
                                   } else {
                                       $('#btn-back-to-top').fadeOut();
                                   }
                               });
                       
                               $('#btn-back-to-top').click(function() {
                                   $('body,html').animate({
                                       scrollTop: 0
                                   }, 800);
                                   return false;
                               });
                           });
                       
                           if ($("#timespanModal").length) {
                               table.button().add("1", {
                                   text: 'Timespan',
                                   className: "btn btn-primary",
                                   init: function(api, node, config) {
                                       $(node).removeClass('dt-button dropdown-item');
                                   },
                                   attr: {
                                       id: 'timespanBtn'
                                   },
                                   action: function(e, dt, button, config) {
                                       $('#timespanModal').modal('toggle');
                                   },
                               });
                           }
                       });
                       ]]>
                    </script>
                </xsl:if>
                <!-- Tooltip for Show more -->
                <xsl:if test="oai:OAI-PMH/oai:ListSets or oai:OAI-PMH/oai:ListIdentifiers or oai:OAI-PMH/oai:ListRecords">
                    <script>
                        <![CDATA[
                        $(document).ready(function () {  
                           $('[data-bs-toggle="tooltip"]').tooltip(); 
                        });

                        $('#timespanSetBtn').click(function() {
                           var newUrl = window.location.href;
                           const timespanFromInput = $('#timespanFromInput').val();
                           const timespanUntilInput = $('#timespanUntilInput').val();
                       
                           if (timespanFromInput.length > 0 && newUrl.indexOf("from=") >= 0) {
                               newUrl = newUrl.replace(/([\?\&]from=)[^\&]*/gm, '$1' + timespanFromInput);
                           } else if (timespanFromInput.length == 0 && newUrl.indexOf("from=") >= 0) {
                               newUrl = newUrl.replace(/([\?\&]from=)[^\&]*/gm, '');
                           } else if (timespanFromInput.length > 0) {
                               newUrl += "&from=" + timespanFromInput;
                           }
                       
                           if (timespanUntilInput.length > 0 && newUrl.indexOf("until=") >= 0) {
                               newUrl = newUrl.replace(/([\?\&]until=)[^\&]*/gm, '$1' + timespanUntilInput);
                           } else if (timespanUntilInput.length == 0 && newUrl.indexOf("until=") >= 0) {
                               newUrl = newUrl.replace(/([\?\&]until=)[^\&]*/gm, '');
                           } else if (timespanUntilInput.length > 0) {
                               newUrl += "&until=" + timespanUntilInput;
                           }
                           location.href = newUrl;
                       });
                       ]]>
                    </script>
                </xsl:if>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
