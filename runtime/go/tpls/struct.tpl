{{- define "notes"}}
	{{- if ne .Notes "" -}}
// {{.Notes}}
	{{- else}}
		{{- if eq .ValueKind.String "map"}}
{{- template "notes" .Value.MapValue}}
		{{- else if eq .ValueKind.String "array"}}
{{- template "notes" .Value.ArrayValue}}
		{{- end}}
	{{- end}}
{{- end}}

{{- define "fieldTag"}}
{{- graveAccent -}}
json:"{{.Name}}" bson:"{{if eq (toUpper .Name) "ID"}}_id{{else}}{{.Name}}{{end}}"
{{- graveAccent -}}
{{- end}}

{{- define "fieldTagZero"}}
{{- graveAccent}}json:"-" bson:"-"{{graveAccent}}
{{- end}}

{{- define "primitive"}}
	{{- if eq . "datetime" -}}
time.Time
	{{- else if eq . "duration" -}}
wtime.Duration
	{{- else if eq . "i18n" -}}
archivist.I18n
	{{- else -}}
{{.}}
	{{- end}}
{{- end}}

{{- define "pureType"}}
	{{- depth "+"}}
	{{- if eq .ValueKind.String "primitive" -}}
{{template "primitive" .Value.Primitive}}
	{{- else if eq .ValueKind.String "struct"}}
		{{- if eq (depth "v") 1 -}}
struct {
{{""}}
			{{- range .Value.StructFields}}
	{{- template "field" .}}
				{{- if deepToRef .}}
	{{- template "fieldRef" .}}
				{{- end}}
			{{- end -}}
}
		{{- else -}}
*{{toPascal (lookupStructName .)}}
		{{- end}}
	{{- else if eq .ValueKind.String "map" -}}
map[{{.Value.MapKey}}]{{template "pureType" .Value.MapValue}}
	{{- else if eq .ValueKind.String "array" -}}
[]{{template "pureType" .Value.ArrayValue}}
	{{- else if eq .ValueKind.String "ref" -}}
int64
	{{- end}}
	{{- depth "-"}}
{{- end}}

{{- define "field"}}
	{{- depth "+"}}
	{{- if ne .Name ""}}
		{{- "\t"}}{{toPascal .Name}}{{" "}}
	{{- end}}
	{{- if eq .ValueKind.String "primitive" -}}
{{template "primitive" .Value.Primitive}} {{template "fieldTag" .}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "struct" -}}
*{{toPascal (lookupStructName .)}} {{template "fieldTag" .}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "map" -}}
map[{{.Value.MapKey}}]{{template "pureType" .Value.MapValue}} {{template "fieldTag" .}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "array" -}}
[]{{template "pureType" .Value.ArrayValue}} {{template "fieldTag" .}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "ref" -}}
int64 {{template "fieldTag" .}} {{- template "notes" .}}
{{""}}
	{{- end}}
	{{- depth "-"}}
{{- end}}

{{- define "fieldRef"}}
	{{- depth "+"}}
	{{- if ne .Name ""}}
		{{- "\t"}}{{toPascal .Name}}Ref{{" "}}
	{{- end}}
	{{- if eq .ValueKind.String "primitive" -}}
impossible
	{{- else if eq .ValueKind.String "struct" -}}
impossible
{{""}}
	{{- else if eq .ValueKind.String "map" -}}
map[{{.Value.MapKey}}]{{template "pureRef" .Value.MapValue}} {{template "fieldTagZero"}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "array" -}}
[]{{template "pureRef" .Value.ArrayValue}} {{template "fieldTagZero"}} {{- template "notes" .}}
{{""}}
	{{- else if eq .ValueKind.String "ref" -}}
*{{toPascal .Value.Ref}}Item {{template "fieldTagZero"}} {{- template "notes" .}}
{{""}}
	{{- end}}
	{{- depth "-"}}
{{- end}}

{{- define "pureRef"}}
	{{- depth "+"}}
	{{- if eq .ValueKind.String "primitive" -}}
impossible
	{{- else if eq .ValueKind.String "struct" -}}
impossible
	{{- else if eq .ValueKind.String "map" -}}
map[{{.Value.MapKey}}]{{template "pureRef" .Value.MapValue}}
	{{- else if eq .ValueKind.String "array" -}}
[]{{template "pureRef" .Value.ArrayValue}}
	{{- else if eq .ValueKind.String "ref" -}}
*{{toPascal .Value.Ref}}Item
	{{- end}}
	{{- depth "-"}}
{{- end}}

// Code generated by archivist. DO NOT EDIT.

package {{.Pkg}}

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

{{- range $i, $v := .Nodes -}}
{{""}}
{{if gt $i 0 -}}
// {{toPascal (lookupStructName .)}} represents {{.Path}}
{{else -}}
// easyjson:json
{{end -}}
type {{toPascal (lookupStructName .)}} {{template "pureType" .}}
{{- end}}

{{- define "bindRefs"}}
	{{- depth "+"}}
	{{- if eq .ValueKind.String "primitive"}}
	{{- else if eq .ValueKind.String "struct"}}
		{{- if eq (depth "v") 1}}
			{{- range .Value.StructFields}}
				{{- if deepToStruct .}}
					{{- if eq .ValueKind.String "struct" -}}
if err := this.{{toPascal .Name}}.bindRefs(c); err != nil {
	return err
}
{{""}}
					{{- else -}}
{
	v := this.{{toPascal .Name}}
	{{template "bindRefs" .}}
}
{{""}}
					{{- end}}
				{{- else if deepToRef .}}
					{{- if eq .ValueKind.String "ref"}}
{{- template "bindRefs" .}}
					{{- else -}}
{
	this.{{toPascal .Name}}Ref = make({{template "pureRef" .}}, len(this.{{toPascal .Name}}))
	v := this.{{toPascal .Name}}
	r := this.{{toPascal .Name}}Ref
	{{template "bindRefs" .}}
}
{{""}}
					{{- end}}
				{{- end}}
			{{- end}}
		{{- else}}
if err := v.bindRefs(c); err != nil {
	return err
}
{{""}}
		{{- end}}
	{{- else if eq .ValueKind.String "map" -}}
for {{if deepToRef .}}k{{else}}_{{end}}, v := range v {
		{{- if deepToRef .}}
			{{- if eq .Value.MapValue.ValueKind.String "ref" -}}
	if v != 0 {
		r[k], ok = {{template "bindRefs" .Value.MapValue}}
		if !ok {
			return errors.Errorf("<{{jsonFile}}{{.Path}}> {{originalRefName .Value.MapValue.Value.Ref}}[%d] does NOT exist", v)
		}
	} else {
		r[k] = nil
	}
			{{- else -}}
	r[k] = make({{template "pureRef" .Value.MapValue}}, len(v))
{{""}}
				{{- if eq .Value.MapValue.ValueKind.String "map" "array" -}}
	r := r[k]
{{""}}
				{{- end -}}	
	{{template "bindRefs" .Value.MapValue -}}
{{""}}
			{{- end}}
		{{- else -}}
	{{template "bindRefs" .Value.MapValue -}}
		{{- end -}}
}
	{{- else if eq .ValueKind.String "array" -}}
for {{if deepToRef .}}k{{else}}_{{end}}, v := range v {
		{{- if deepToRef .}}
			{{- if eq .Value.ArrayValue.ValueKind.String "ref" -}}
	if v != 0 {
		r[k], ok = {{template "bindRefs" .Value.ArrayValue}}
		if !ok {
			return errors.Errorf("<{{jsonFile}}{{.Path}}> {{originalRefName .Value.ArrayValue.Value.Ref}}[%d] does NOT exist", v)
		}
	} else {
		r[k] = nil
	}
			{{- else -}}
	r[k] = make({{template "pureRef" .Value.ArrayValue}}, len(v))
{{""}}
				{{- if eq .Value.ArrayValue.ValueKind.String "map" "array" -}}
	r := r[k]
{{""}}
				{{- end -}}	
	{{template "bindRefs" .Value.ArrayValue -}}
{{""}}
			{{- end}}
		{{- else -}}
	{{template "bindRefs" .Value.ArrayValue -}}
		{{- end -}}
}
	{{- else if eq .ValueKind.String "ref"}}
		{{- if ne .Name "" -}}
if this.{{toPascal .Name}} != 0 {
	this.{{toPascal .Name}}Ref, ok = c.{{toPascal .Value.Ref}}[this.{{toPascal .Name}}]
	if !ok {
		return errors.Errorf("<{{jsonFile}}{{.Path}}> {{originalRefName .Value.Ref}}[%d] does NOT exist", this.{{toPascal .Name}})
	}
} else {
	this.{{toPascal .Name}}Ref = nil
}
{{""}}
		{{- else -}}
c.{{toPascal .Value.Ref}}[v]
		{{- end}}
	{{- end}}
	{{- depth "-"}}
{{- end}}

{{- range .Nodes -}}
{{""}}

func (this *{{toPascal (lookupStructName .)}}) bindRefs(c *Collection) error {
	if this == nil {
		return nil
	}

	var ok bool
	_ = ok
{{""}}
	{{- if or (deepToStruct .) (deepToRef .) -}}
		{{- if eq .ValueKind.String "map" "array" -}}
	v := *this
{{""}}
		{{- end -}}
		{{- template "bindRefs" . -}}
	{{- end -}}
{{""}}

	return nil
}
{{- end}}