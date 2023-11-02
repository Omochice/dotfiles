import {{_name_}} from "{{_cursor_}}";
import type { Meta, StoryObj } from "@storybook/vue3";

type Story = StoryObj<typeof {{_name_}}>;

const meta: Meta<typeof {{_name_}}> = {
  title: "{{_name_}}",
  component: {{_name_}},
};

export const Default: Story = {
  render: () => ({
    components: { {{_name_}} },
    template: "<{_name_} />",
  }),
};

export default meta;
