/* 
 * Copyright 2019-2021 Michael Büchner, Deutsche Digitale Bibliothek
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package de.ddb.labs.b4oai;

import io.javalin.Javalin;
import io.javalin.http.ContentType;
import io.javalin.http.Context;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.concurrent.TimeUnit;
import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.apache.tika.Tika;

/**
 *
 * @author Michael Büchner
 */
public class Main {

    private final Tika tika = new Tika();

    private static final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(1, TimeUnit.MINUTES)
            .callTimeout(1, TimeUnit.MINUTES)
            .readTimeout(5, TimeUnit.MINUTES)
            .build();

    public static void main(String[] args) throws IOException {
        new Main().run();
    }

    void run() {

        // start javalin server
        final Javalin app = Javalin.create(config -> {
            config.autogenerateEtags = true;
            config.enableCorsForAllOrigins();
        }).events(event -> {
        }).start(8080);

        // set UTF-8 as default charset
        app.before(ctx -> ctx.res.setCharacterEncoding("UTF-8"));
        app.get("/", ctx -> {
            runRequest(ctx);

        });

        app.get("/<path>", ctx -> {

            if (ctx.pathParam("path").startsWith("res/")) {
                final URL u = Main.class.getResource("/" + ctx.pathParam("path"));
                final String mimeType = tika.detect(u);

                ctx.contentType(mimeType);
                ctx.result(new FileInputStream(u.getPath()));
                return;
            }
            runRequest(ctx);

        });
    }

    void runRequest(Context ctx) throws IOException {
        String u = null;
        try {
            u = ctx.pathParam("path");
        } catch (Exception e) {
            // nothing
        }
        String q = ctx.req.getQueryString();

        System.out.println("OrigURL: " + ctx.fullUrl());

        final String url = "https://oai.deutsche-digitale-bibliothek.de/" + (u != null ? u : "") + (q != null ? "?" + q : "");
        // final String url = "https://services.dnb.de/oai/repository" + (u != null ? u : "") + (q != null ? "?" + q : "");
        // final String url = "http://export.arxiv.org/oai2/" + (u != null ? u : "") + (q != null ? "?" + q : "");
        System.out.println("URL: " + url);

        final Request request = new Request.Builder()
                .url(url)
                .build();

        final Call call = client.newCall(request);
        try ( Response response = call.execute()) {

            String ct = response.headers().get("Content-Type");
            if (ct.contains(";")) {
                ct = ct.substring(0, ct.indexOf(";"));
            }
            final ContentType rct = ContentType.getContentType(ct);
            ctx.contentType(rct);

            if (rct.equals(ContentType.TEXT_XML)) {
                String r = response.body().string();

                r = r.replaceAll("<\\?[^\\>]*>", "");

                final String lineOne = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
                        + "<?xml-stylesheet type=\"text/xsl\" href=\"/res/b4oai.xsl\"?>";

                r = lineOne + r;

                r = r.replaceAll("http://oai.deutsche-digitale-bibliothek.de/oai/OAIHandler", "http://localhost:8080");
                r = r.replaceAll("http://oai.deutsche-digitale-bibliothek.de", "http://localhost:8080");
                r = r.replaceAll("https://oai.deutsche-digitale-bibliothek.de", "http://localhost:8080");
                r = r.replaceAll("http://services.dnb.de/oai/repository", "http://localhost:8080");
                r = r.replaceAll("https://services.dnb.de/oai/repository", "http://localhost:8080");
                r = r.replaceAll("http://export.arxiv.org/oai2", "http://localhost:8080");
                ctx.result(r);
            } else {
                ctx.result(response.body().bytes());
            }
        }
    }
}
