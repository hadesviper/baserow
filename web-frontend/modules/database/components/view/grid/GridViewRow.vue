<template>
  <div
    class="grid-view__row"
    :class="{
      'grid-view__row--selected': row._.selectedBy.length > 0,
      'grid-view__row--loading': row._.loading,
      'grid-view__row--hover': row._.hover,
      'grid-view__row--warning':
        !row._.matchFilters || !row._.matchSortings || !row._.matchSearch,
    }"
    @mouseover="$emit('row-hover', { row, value: true })"
    @mouseleave="$emit('row-hover', { row, value: false })"
    @contextmenu.prevent="$emit('row-context', { row, event: $event })"
  >
    <template v-if="includeRowDetails">
      <div
        v-if="!row._.matchFilters || !row._.matchSortings || !row._.matchSearch"
        class="grid-view__row-warning"
      >
        <template v-if="!row._.matchFilters">
          {{ $t('gridViewRow.rowNotMatchingFilters') }}
        </template>
        <template v-else-if="!row._.matchSearch">
          {{ $t('gridViewRow.rowNotMatchingSearch') }}
        </template>
        <template v-else-if="!row._.matchSortings">{{
          $t('gridViewRow.rowHasMoved')
        }}</template>
      </div>
      <div
        class="grid-view__column"
        :style="{ width: gridViewRowDetailsWidth + 'px' }"
      >
        <div
          class="grid-view__row-info"
          :class="{
            'grid-view__row-info--matches-search':
              row._.matchSearch && row._.fieldSearchMatches.includes('row_id'),
          }"
        >
          <div
            class="grid-view__row-count"
            :class="{ 'grid-view__row-count--small': row.id > 9999 }"
            :title="row.id"
          >
            {{ row.id }}
          </div>
          <div
            v-if="!readOnly && canDrag"
            class="grid-view__row-drag"
            @mousedown="startDragging($event, row)"
          ></div>
          <component
            :is="rowExpandButton"
            :row="row"
            @edit-modal="$emit('edit-modal', row)"
          ></component>
        </div>
      </div>
    </template>
    <!--
    Somehow re-declaring all the events instead of using v-on="$listeners" speeds
    everything up because the rows don't need to be updated everytime a new one is
    rendered, which happens a lot when scrolling.
    -->
    <GridViewCell
      v-for="field in fields"
      :key="'row-field-' + row.id + '-' + field.id.toString()"
      :field="field"
      :row="row"
      :state="state"
      :multi-select-position="getMultiSelectPosition(row.id, field)"
      :read-only="readOnly"
      :style="{ width: fieldWidths[field.id] + 'px' }"
      @update="$emit('update', $event)"
      @edit="$emit('edit', $event)"
      @select="$emit('select', $event)"
      @unselect="$emit('unselect', $event)"
      @selected="$emit('selected', $event)"
      @unselected="$emit('unselected', $event)"
      @select-next="$emit('select-next', $event)"
      @cell-mousedown-left="$emit('cell-mousedown-left', { row, field })"
      @cell-mouseover="$emit('cell-mouseover', { row, field })"
      @cell-mouseup-left="$emit('cell-mouseup-left', { row, field })"
    ></GridViewCell>
  </div>
</template>

<script>
import GridViewCell from '@baserow/modules/database/components/view/grid/GridViewCell'
import gridViewHelpers from '@baserow/modules/database/mixins/gridViewHelpers'
import GridViewRowExpandButton from '@baserow/modules/database/components/view/grid/GridViewRowExpandButton'

export default {
  name: 'GridViewRow',
  components: { GridViewRowExpandButton, GridViewCell },
  mixins: [gridViewHelpers],
  props: {
    row: {
      type: Object,
      required: true,
    },
    fields: {
      type: Array,
      required: true,
    },
    allFieldIds: {
      type: Array,
      required: true,
    },
    fieldWidths: {
      type: Object,
      required: true,
    },
    includeRowDetails: {
      type: Boolean,
      required: false,
      default: () => false,
    },
    readOnly: {
      type: Boolean,
      required: true,
    },
    canDrag: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      // The state can be used by functional components to make changes to the dom.
      // This is for example used by the functional file field component to enable the
      // drop effect without having the cell selected.
      state: {},
      // A list containing field id's of field cells that must not be converted to the
      // functional component even though the user has selected another cell. This is
      // for example used by the file field to finish the uploading task if the user
      // has selected another cell while uploading.
      alive: [],
      rowExpandButton: this.$registry
        .get('application', 'database')
        .getRowExpandButtonComponent(),
    }
  },
  methods: {
    isCellSelected(fieldId) {
      return this.row._.selected && this.row._.selectedFieldId === fieldId
    },
    selectCell(fieldId, rowId = this.row.id) {
      this.$store.dispatch(this.storePrefix + 'view/grid/setSelectedCell', {
        rowId,
        fieldId,
      })
    },
    // Return an object that represents if a cell is selected,
    // and it's current position in the selection grid
    getMultiSelectPosition(rowId, field) {
      const position = {
        selected: false,
        top: false,
        right: false,
        bottom: false,
        left: false,
      }
      if (
        this.$store.getters[this.storePrefix + 'view/grid/isMultiSelectActive']
      ) {
        const rowIndex =
          this.$store.getters[
            this.storePrefix + 'view/grid/getMultiSelectRowIndexById'
          ](rowId)

        let fieldIndex = this.allFieldIds.findIndex((id) => field.id === id)
        fieldIndex += !field.primary ? 1 : 0

        const [minRow, maxRow] =
          this.$store.getters[
            this.storePrefix + 'view/grid/getMultiSelectRowIndexSorted'
          ]
        const [minField, maxField] =
          this.$store.getters[
            this.storePrefix + 'view/grid/getMultiSelectFieldIndexSorted'
          ]

        if (rowIndex >= minRow && rowIndex <= maxRow) {
          if (fieldIndex >= minField && fieldIndex <= maxField) {
            position.selected = true
            if (rowIndex === minRow) {
              position.top = true
            }
            if (rowIndex === maxRow) {
              position.bottom = true
            }
            if (fieldIndex === minField) {
              position.left = true
            }
            if (fieldIndex === maxField) {
              position.right = true
            }
          }
        }
      }
      return position
    },
    setState(value) {
      this.state = value
    },
    addKeepAlive(fieldId) {
      if (!this.alive.includes(fieldId)) {
        this.alive.push(fieldId)
      }
    },
    removeKeepAlive(fieldId) {
      const index = this.alive.findIndex((id) => id === fieldId)
      if (index > -1) {
        this.alive.splice(index, 1)
      }
    },
    startDragging(event, row) {
      if (this.readOnly) {
        return
      }

      event.preventDefault()
      this.$emit('row-dragging', { row, event })
    },
  },
}
</script>
