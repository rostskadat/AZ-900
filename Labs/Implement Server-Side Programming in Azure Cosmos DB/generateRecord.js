function generateRecord(name, value) {
    var doc = {
        description: name, reading: value,
        stamp: new Date(), group: "records"
    };
    __.createDocument(__.getSelfLink(), doc, documentCreated);
}
function documentCreated(error, newDoc) {
    if (error) throw new Error(error.message);
    getContext().getResponse().setBody(newDoc);
}