// Code generated by go-swagger; DO NOT EDIT.

package metadata

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	"github.com/go-openapi/runtime/middleware"
)

// GetMetaHandlerFunc turns a function with the right signature into a get meta handler
type GetMetaHandlerFunc func(GetMetaParams, interface{}) middleware.Responder

// Handle executing the request and returning a response
func (fn GetMetaHandlerFunc) Handle(params GetMetaParams, principal interface{}) middleware.Responder {
	return fn(params, principal)
}

// GetMetaHandler interface for that can handle valid get meta params
type GetMetaHandler interface {
	Handle(GetMetaParams, interface{}) middleware.Responder
}

// NewGetMeta creates a new http.Handler for the get meta operation
func NewGetMeta(ctx *middleware.Context, handler GetMetaHandler) *GetMeta {
	return &GetMeta{Context: ctx, Handler: handler}
}

/*
	GetMeta swagger:route GET /meta Metadata getMeta

# Get metadata for all POST APIs

Returns metadata about required fields for each POST API.
*/
type GetMeta struct {
	Context *middleware.Context
	Handler GetMetaHandler
}

func (o *GetMeta) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewGetMetaParams()
	uprinc, aCtx, err := o.Context.Authorize(r, route)
	if err != nil {
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}
	if aCtx != nil {
		*r = *aCtx
	}
	var principal interface{}
	if uprinc != nil {
		principal = uprinc.(interface{}) // this is really a interface{}, I promise
	}

	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params, principal) // actually handle the request
	o.Context.Respond(rw, r, route.Produces, route, res)

}
