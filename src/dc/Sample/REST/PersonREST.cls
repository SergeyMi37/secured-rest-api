Class dc.sample.rest.PersonREST Extends dc.sample.rest.Base
{

Parameter Version = "1.0.0";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Get all records of Person class -->
<Route Url="/persons/all" Method="GET" Call="GetAllPersons"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
<!-- GET method to return JSON for a given person id-->
<Route Url="/persons/:id" Method="GET" Call="GetPerson"/>
<!-- Update a person with id-->
<Route Url="/persons/:id" Method="PUT" Call="UpdatePerson"/>
<!-- Delete a person with id-->
<Route Url="/persons/:id" Method="DELETE" Call="DeletePerson"/>
<!-- Create a person-->
<Route Url="/persons/" Method="POST" Call="CreatePerson"/>

</Routes>
}

/// PersonsREST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

/// Retreive all the records of Sample.Person
ClassMethod GetAllPersons() As %Status
{

    #dim tSC As %Status = $$$OK
    if '($ROLES["Reader") {
        Set %response.Status = 403
        return tSC }   

    Set rset = ##class(Person).ExtentFunc()

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Write "["
    if rset.%Next() {
        Set person = ##class(Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    While rset.%Next() {   
        Write ","
        Set person = ##class(Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    Write "]"
    Quit tSC
}

/// Return one record fo Sample.Person
ClassMethod GetPerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    if '($ROLES["Reader") {
        Set %response.Status = 403
        return tSC }   


    #; Set the response header to plain text
    Set %response.ContentType = ..#CONTENTTYPEJSON

    Set person = ##class(Person).%OpenId(id)

    If '$IsObject(person) Quit ..Http404()

    Do person.%JSONExport()

    Quit tSC
}

/// Creates a new Sample.Person record
ClassMethod CreatePerson() As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
     if '($ROLES["Writer") {
        Set %response.Status = 403
        return tSC }   

    Set person = ##class(Person).%New()
    Set data=%request.Content


    $$$TOE(tSC,person.%JSONImport(data))
    $$$TOE(tSC,person.%Save())

    Set %response.Status = 204
    Set %response.ContentType = ..#CONTENTTYPEJSON
    //d data.%ToJSON()
    Do person.%JSONExport()

    Quit tSC
}

/// Update a record in Sample.Person with id
ClassMethod UpdatePerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    s ^AAA=$ROLES
    if '($ROLES["Writer") {
        Set %response.Status = 403
        return tSC }   

    Set person = ##class(Person).%OpenId(id)
    If '$IsObject(person) Return ..Http404()
    Set data=%request.Content

    $$$TOE(tSC,person.%JSONImport(data))
    $$$TOE(tSC,person.%Save())

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Do person.%JSONExport()

    Quit tSC
}

/// Delete a record with id in Sample.Person
ClassMethod DeletePerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set person = ##class(Person).%OpenId(id)
    If '$IsObject(person) Return ..Http404()

    $$$TOE(tSC,person.%DeleteId(id))

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON

    Quit tSC
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/crud"
  Set swagger.info.title = "InterSystems IRIS REST CRUD demo"
  Set swagger.info.version = "1"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

}