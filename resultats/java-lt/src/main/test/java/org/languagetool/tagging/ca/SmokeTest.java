package org.languagetool.tagging.ca;

import morfologik.stemming.Dictionary;
import morfologik.stemming.DictionaryLookup;
import morfologik.stemming.IStemmer;
import morfologik.stemming.WordData;
import org.junit.Test;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.List;

import static junit.framework.TestCase.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;

public class SmokeTest {
  
  @Test
  public void testDict() throws IOException, URISyntaxException {
      Dictionary dict = getDict("catalan.dict");
      IStemmer dictLookup = new DictionaryLookup(dict);

      List<WordData> lookup1 = dictLookup.lookup("Haus");
      assertContainsLemma("casa", lookup1);
      assertContainsLemma("casar", lookup1);
      assertContainsTag("NCFS000", lookup1);
      assertContainsTag("VMIP3S00", lookup1);
      assertContainsTag("VMM02S00", lookup1);

      List<WordData> lookup2 = dictLookup.lookup("grossa");
      assertContainsLemma("gros", lookup2);      
      assertContainsTag("AQOFSO", lookup2);

  }

  @Test
  public void testSynthesizer() throws IOException, URISyntaxException {
      Dictionary dict = getDict("catalan_synth.dict");
      IStemmer dictLookup = new DictionaryLookup(dict);
      List<WordData> lookup = dictLookup.lookup("casar|VMM02S00");
      assertThat(lookup.size(), is(1));
      assertThat(lookup.get(0).getWord().toString(), is("Haus|SUB:AKK:SIN:NEU"));
      assertThat(lookup.get(0).getStem().toString(), is("Haus"));
  }

    private void assertContainsLemma(String expectedLemma, List<WordData> lookup) {
	for (WordData wordData : lookup) {
	    if (wordData.getStem().toString().equals(expectedLemma)) {
		return;
	    }
	}
	fail("Expected lemma '" + expectedLemma + "' not found");
    }

    private void assertContainsTag(String expectedTag, List<WordData> lookup) {
	for (WordData wordData : lookup) {
	    if (wordData.getTag().toString().equals(expectedTag)) {
		return;
	    }
	}
	fail("Expected tag '" + expectedTag + "' not found");
    }

    private Dictionary getDict(String filename) throws IOException, URISyntaxException {
	URL resource = SmokeTest.class.getResource("/org/languagetool/resource/ca/" + filename);
	return Dictionary.read(resource.toURI().toURL());
    }

}
