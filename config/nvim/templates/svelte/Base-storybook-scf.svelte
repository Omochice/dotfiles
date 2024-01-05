<script context="module">
  import ComponentName from "./ComponentName.svelte";

  export const meta = {
    title:"ComponentName",
    component:ComponentName,
  };
</script>

<script>
  import { Template, Story } from "@storybook/addon-svelte-csf";
</script>

<Template let:args>
  <ComponentName />
</Template>

<Story
  name="Primary"
  args={{}}
/>
