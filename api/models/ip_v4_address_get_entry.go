// Code generated by go-swagger; DO NOT EDIT.

package models

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"
	"github.com/go-openapi/validate"
)

// IPV4AddressGetEntry IPv4 address get entry
//
// swagger:model IPv4AddressGetEntry
type IPV4AddressGetEntry struct {

	// Name of the interface device to which you want to modify the IP address
	Dev string `json:"dev,omitempty"`

	// ip address
	IPAddress []string `json:"ipAddress"`

	// Sync - sync state
	// Required: true
	Sync *int64 `json:"sync"`
}

// Validate validates this IPv4 address get entry
func (m *IPV4AddressGetEntry) Validate(formats strfmt.Registry) error {
	var res []error

	if err := m.validateSync(formats); err != nil {
		res = append(res, err)
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}

func (m *IPV4AddressGetEntry) validateSync(formats strfmt.Registry) error {

	if err := validate.Required("sync", "body", m.Sync); err != nil {
		return err
	}

	return nil
}

// ContextValidate validates this IPv4 address get entry based on context it is used
func (m *IPV4AddressGetEntry) ContextValidate(ctx context.Context, formats strfmt.Registry) error {
	return nil
}

// MarshalBinary interface implementation
func (m *IPV4AddressGetEntry) MarshalBinary() ([]byte, error) {
	if m == nil {
		return nil, nil
	}
	return swag.WriteJSON(m)
}

// UnmarshalBinary interface implementation
func (m *IPV4AddressGetEntry) UnmarshalBinary(b []byte) error {
	var res IPV4AddressGetEntry
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*m = res
	return nil
}