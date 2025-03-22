---
layout: post
title: "Firefox AI & WebExtensions"
location: Clermont-Fd Area, France
image: /images/posts/2025/03/ai-social.webp
tags: [mozilla]
# mastodon_id:
---

_I gave an introduction to the Firefox AI runtime and WebExtensions at a [French
local conference][clermontech] this month. This article is a loose transcript of
what I said._

Let's talk about Firefox, AI, and WebExtensions.

## Browser extensions

Browser extensions are tiny applications that modify and/or add features to a
web browser. Nowadays, these small programs can be written in such a way that
they should be compatible with different browsers.

That's because there exists a cross-browser system called "WebExtensions", which
– among other things – provides a set of common APIs that browser extensions can
use. In addition to that, browsers can also expose their own APIs, and we'll see
that in a moment.

You'll find a lot more information on this [MDN page][mdn-webextensions].

**Note:** During my talk, I used the [Borderify extension][mdn-firstextension]
to walk the audience through an example of a web extension. I then concluded
that it's super easy to get started but also very powerful. Extensions like
uBlock Origin, Dark Reader, 1Password, etc. are rather powerful and
sophisticated features.

## Firefox AI runtime

Firefox has a new [component][firefox-ml] based on [Transformers.js][] and the
[ONNX runtime][] to perform local inference directly in the browser.  In short,
this runtime allows to use a model from [Hugging Face][] (like GitHub but for
Machine Learning models) directly in Firefox[^1], without the need to send data
to any servers. Every operation is performed on the user's machine once the
model files have been downloaded by Firefox.

While every website could technically load Transformers.js and a model, this
isn't very efficient. Say two websites use the same model, you end up with two
copies of the model files. And those aren't exactly small.

This Firefox component – also known as the Firefox (AI) runtime – addresses this
problem by ensuring that models are shared. In addition, this runtime takes care
of managing resources, and model inference is isolated from the rest of Firefox
in an _inference_ process.

**Note:** During my talk, I mentioned that – while we call this "AI" now –
Mozilla has been doing Machine Learning (ML) for a very long time[^2]. For
instance, Firefox Translations isn't exactly [new][firefox-translations-repo],
and whether you like it or not, this is clearly an application of Generative
AI[^3]. Same thing, still.

Anyway, let's see how we can interact with this runtime. We're going to generate
text that describes an image in the rest of this section.

The "hacker's approach" is probably to open a [Browser console][] in
[Nightly][], and run some privileged JavaScript code:

```js
const { createEngine } = ChromeUtils.importESModule(
  "chrome://global/content/ml/EngineProcess.sys.mjs"
);

const options = {
  taskName: "image-to-text",
  modelHub: "mozilla",
};
const engine = await createEngine(options);

const [res] = await engine.run({
  args: ["https://williamdurand.fr/images/posts/2014/12/brussels.jpg"],
});
// res => { generated_text: "A large poster of a man on a wall." }
```

As mentioned previously, the Firefox runtime is based on Transformers.js, which
is why the code looks familiar when you know Transformers already. For instance,
instead of passing an actual model here, we pass a _task name_. That's an
abstraction coming from Transformers. Don't worry, we can also pass a model name
and a lot of other (pipeline) options!

For those looking for a more graphical approach to play with this AI runtime,
Firefox Nightly provides an `about:inference` page that looks like this:

![Screenshot of the about:inference page](/images/posts/2025/03/aboutinference.webp)
<!-- add some space between the image and the next paragraph --><br>

That's cool but... Why? Well, it turns out this example isn't a random example.
This code snippet is an overly simplified version of a feature in Firefox's PDF
reader ([PDF.js][] ❤️): alt text generation[^4].

![](/images/posts/2025/03/pdfjs.webp)
_Screenshot of an "Edit alt text" dialog in PDF.js (inside Firefox): the image
description has been automatically generated._
{:.with-caption}

**Note**: During my talk, someone asked a question about the use of GPU, for
which I didn't have the answer. I do have it now, though. The Firefox AI runtime
runs on CPU by default, but it is possible to run on GPU via [WebGPU][]. It's
worth mentioning that this runtime doesn't feel as fast as a more "native"
solution (like [Ollama][]) yet but the team at Mozilla is working on it!

Anyhow, let's move to the final part of this ~~talk~~ article.

## WebExtensions ML API

The best of both worlds, yay!

We shipped an experimental WebExtensions API to allow extensions to do local
inference ([docs][trial-ml]), leveraging the Firefox AI runtime under the hood.
Expect things to evolve, it's bleeding edge technology!

At the time of writing this, we can rewrite the example from the previous
section into "extension code" as follows:

```js
const options = {
  taskName: "image-to-text",
  modelHub: "mozilla",
};
await browser.trial.ml.createEngine(options);

const [res] = await browser.trial.ml.runEngine({
  args: ["https://williamdurand.fr/images/posts/2014/12/brussels.jpg"],
});
// res => { generated_text: "A large poster of a man on a wall." }
```

This looks similar, right? That's on purpose. For extension developers, the
WebExtensions API namespace is `trial.ml`, and the associated permission is
named `trialML`, which extensions must [request at runtime][].

What can we do with that, though?  Well, what if we were to provide the
alt-text-generation feature not just in PDFs but for any image on any website?

That's what we have done in a demo extension ([code][demo-extension-sources],
[docs][demo-extension-docs]), which we can see in action in the screencast
below:

- At 00:00, the demo extension has been loaded in Firefox Nightly.
- At 00:02, we open the context menu on an image in the current web page, and we
  click on "Generate Alt Text". This menu entry has been added by the extension
  using the [`menus` API][menus-api] by the way.
- At 00:05, we can see that Firefox is downloading the model files (the UI is
  provided by the extension, which receives events from Firefox). This means the
  model was not used before so the Firefox AI runtime has to download the model
  files first. This step is only necessary when Firefox doesn't already have the
  model used by the extension.
- At 00:09, the model inference starts.
- At 00:12, the result of the inference, which is the description of the image
  in this case, is returned to the extension, and the extension shows it to
  the user.

<video controls>
  <source src="/images/posts/2025/03/demo_webext_trial_ml_desktop.webm" type="video/webm" />
  <p>Your browser doesn't support HTML video.</p>
</video>

Previously, I mentioned that browser extensions can be cross-browser. They can
also run on different platforms as well. In [Bug 1954362][], I updated this demo
extension so that it can run on [Firefox for Android][android-addons] 😎

The screencast below shows the same extension running in Firefox for Android:

- At 00:00, we can see a dialog because the extension has _just_ been installed.
- At 00:01, the extension opened a page in a new tab to request permission to
  interact with the Firefox AI runtime. This is pretty standard for browser
  extensions to request permissions ahead of time.
- At 00:06, we load a web page with an image.
- At 00:10, we use long-press on the image to trigger the extension because
  the `menus` API is not supported on Android yet ([Bug 1595822][]).
- At 00:12, similar to the previous screencast, Firefox starts by downloading
  the model files. This takes a lot of time because my emulator isn't exactly
  fast. Do remember that this is only needed once, though.
- At 01:09, the model inference starts.
- At 01:12, the result of the inference, which is – again – the description of
  the image, is returned to the extension, and the extension shows it to the
  user.

<video controls height="500">
  <source src="/images/posts/2025/03/demo_webext_trial_ml_android.webm" type="video/webm" />
  <p>Your browser doesn't support HTML video.</p>
</video>

And that's basically it.

I am personally looking forward to see what extension developers could do with
this new capability in Firefox! And since this is related to my work at Mozilla,
feel free to get in touch if you have questions.

[^1]: Mozilla has its own "hub" too, so it isn't _just_ from Hugging Face.
[^2]: I wrote a bit about my use of ML at work in 2019 [in this article][blog-post-promo].
[^3]: Firefox Translations generates text so this can be considered Generative AI. A major difference is that this doesn't rely on a Large Language Model (LLM). Instead, Translations uses (Marian) Neural Machine Translation (NMT) models and the [Bergamot][] runtime.
[^4]: My colleague Tarek wrote [an extensive Hacks article about this in 2024][hacks].

[clermontech]: https://www.clermontech.org/
[mdn-webextensions]: https://developer.mozilla.org/docs/Mozilla/Add-ons/WebExtensions
[mdn-firstextension]: https://developer.mozilla.org/docs/Mozilla/Add-ons/WebExtensions/Your_first_WebExtension
[firefox-ml]: https://firefox-source-docs.mozilla.org/toolkit/components/ml/
[transformers.js]: https://huggingface.co/docs/transformers.js/
[onnx runtime]: https://onnxruntime.ai/
[hugging face]: https://huggingface.co/
[firefox-translations-repo]: https://github.com/mozilla/firefox-translations
[blog-post-promo]: {% post_url 2021-02-26-i-got-a-promotion %}
[browser console]: https://firefox-source-docs.mozilla.org/devtools-user/browser_console/index.html
[nightly]: https://nightly.mozilla.org
[pdf.js]: https://github.com/mozilla/pdf.js
[hacks]: https://hacks.mozilla.org/2024/05/experimenting-with-local-alt-text-generation-in-firefox-nightly/
[trial-ml]: https://firefox-source-docs.mozilla.org/toolkit/components/ml/extensions.html
[request at runtime]: https://developer.mozilla.org/docs/Mozilla/Add-ons/WebExtensions/API/permissions/request
[demo-extension-sources]: https://searchfox.org/mozilla-central/source/toolkit/components/ml/docs/extensions-api-example
[demo-extension-docs]: https://firefox-source-docs.mozilla.org/toolkit/components/ml/extensions-api-example/README.html
[menus-api]: https://developer.mozilla.org/docs/Mozilla/Add-ons/WebExtensions/API/menus
[android-addons]: https://blog.mozilla.org/addons/2024/05/02/1000-firefox-for-android-extensions-now-available/
[bug 1954362]: https://bugzilla.mozilla.org/show_bug.cgi?id=1954362
[bug 1595822]: https://bugzilla.mozilla.org/show_bug.cgi?id=1595822
[bergamot]: https://browser.mt/
[webgpu]: https://developer.mozilla.org/docs/Web/API/WebGPU_API
[ollama]: https://ollama.com/
