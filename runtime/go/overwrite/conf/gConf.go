// Code generated by archivist. DO NOT EDIT.

package conf

import (
	"time"

	"github.com/kingsgroupos/archivist/runtime/go/archivist"
	"github.com/kingsgroupos/misc/wtime"
	"github.com/pkg/errors"
)

var (
	_ = time.After
	_ = errors.New
	_ = archivist.NewArchivist
	_ = wtime.ParseDuration
)

// easyjson:json
type GConf map[string]int64

func (this *GConf) bindRefs(c *Collection) error {
	if this == nil {
		return nil
	}

	var ok bool
	_ = ok

	return nil
}