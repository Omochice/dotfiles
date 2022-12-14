import {{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0]}} from "{{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0] .. '.vue'}}";

export default {
  title: "{{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0]}}",
  component: {{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0]}},
};

const Template = (args) => ({
  components: { {{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0]}} },
  setup() {
    return { args };
  },
  template: `<{{_expr_:split(fnamemodify(expand('%'), ':t'), '\.')[0]}} />`,
});

export const Sample = Template.bind({});
Sample.args = {
};
