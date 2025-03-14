// Code generated by go-swagger; DO NOT EDIT.

package auth

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	"github.com/go-openapi/runtime/middleware"
)

// GetOauthProviderCallbackHandlerFunc turns a function with the right signature into a get oauth provider callback handler
type GetOauthProviderCallbackHandlerFunc func(GetOauthProviderCallbackParams) middleware.Responder

// Handle executing the request and returning a response
func (fn GetOauthProviderCallbackHandlerFunc) Handle(params GetOauthProviderCallbackParams) middleware.Responder {
	return fn(params)
}

// GetOauthProviderCallbackHandler interface for that can handle valid get oauth provider callback params
type GetOauthProviderCallbackHandler interface {
	Handle(GetOauthProviderCallbackParams) middleware.Responder
}

// NewGetOauthProviderCallback creates a new http.Handler for the get oauth provider callback operation
func NewGetOauthProviderCallback(ctx *middleware.Context, handler GetOauthProviderCallbackHandler) *GetOauthProviderCallback {
	return &GetOauthProviderCallback{Context: ctx, Handler: handler}
}

/*
	GetOauthProviderCallback swagger:route GET /oauth/{provider}/callback auth getOauthProviderCallback

# OAuth callback

Handles the OAuth callback flow for the specified provider.
*/
type GetOauthProviderCallback struct {
	Context *middleware.Context
	Handler GetOauthProviderCallbackHandler
}

func (o *GetOauthProviderCallback) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewGetOauthProviderCallbackParams()
	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params) // actually handle the request
	o.Context.Respond(rw, r, route.Produces, route, res)

}
